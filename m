From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: simplify code structure in addrconf.c/manage_tempaddrs
Date: Mon, 31 Mar 2014 21:21:39 +0200
Message-ID: <20140331192139.GD24150@order.stressinduktion.org>
References: <5339B84E.7030708@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Heiner Kallweit <heiner.kallweit@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42705 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbaCaTVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 15:21:42 -0400
Content-Disposition: inline
In-Reply-To: <5339B84E.7030708@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 08:47:42PM +0200, Heiner Kallweit wrote:
> read_unlock_bh can be moved out of the if clause
> 
> Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>
> ---
>  net/ipv6/addrconf.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 6c7fa08..a65812f 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2122,6 +2122,7 @@ static void manage_tempaddrs(struct inet6_dev *idev,
>  		if (!(flags&IFA_F_TENTATIVE))
>  			ipv6_ifa_notify(0, ift);
>  	}
> +	read_unlock_bh(&idev->lock);
>  
>  	if ((create || list_empty(&idev->tempaddr_list)) &&
>  	    idev->cnf.use_tempaddr > 0) {
> @@ -2130,10 +2131,7 @@ static void manage_tempaddrs(struct inet6_dev *idev,
>  		 * Also create a temporary address if it's enabled but
>  		 * no temporary address currently exists.
>  		 */
> -		read_unlock_bh(&idev->lock);
>  		ipv6_create_tempaddr(ifp, NULL);
> -	} else {
> -		read_unlock_bh(&idev->lock);

Doesn't the lock also protect the list_empty? I remember there is
a list_empty_careful to check concurrently if empty during possible
modification. I actually would leave it as is.

Thanks,

  Hannes
