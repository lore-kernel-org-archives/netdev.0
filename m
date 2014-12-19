From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net-next] netdevice: optimise netdev_intersect_features
 slightly
Date: Fri, 19 Dec 2014 07:09:38 +0100
Message-ID: <20141219060938.GA6909@unicorn.suse.cz>
References: <1418966487-23347-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53077 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230AbaLSGJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 01:09:40 -0500
Content-Disposition: inline
In-Reply-To: <1418966487-23347-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2014 at 01:21:27PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Since f1 and f2 always have NETIF_F_GEN_CSUM when doing Bitwise OR assignment,
> it is unnecessory to clear NETIF_F_GEN_CSUM from the added data
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Cc: Michal Kubecek <mkubecek@suse.cz>
> ---
>  include/linux/netdevice.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index c31f74d..b8facf9 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3542,9 +3542,9 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
>  							  netdev_features_t f2)
>  {
>  	if (f1 & NETIF_F_GEN_CSUM)
> -		f1 |= (NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
> +		f1 |= NETIF_F_ALL_CSUM;
>  	if (f2 & NETIF_F_GEN_CSUM)
> -		f2 |= (NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);
> +		f2 |= NETIF_F_ALL_CSUM;
>  	f1 &= f2;
>  	if (f1 & NETIF_F_GEN_CSUM)
>  		f1 &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_GEN_CSUM);

This is not an optimization in the sense of resulting code as the
expression right of "|=" is a constant so the patch just replaces or
with one constant by an or with a different one. But the source looks
nicer so it may make sense anyway.

However, I will have to take a look at both versions of the resulting
code first as we are using the same expression (or its bitwise inverse)
later so that current version might be actually slightly more efficient.

                                                         Michal Kubecek
