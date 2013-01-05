From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix NULL checking in devinet_ioctl()
Date: Sat, 05 Jan 2013 15:10:02 -0800
Message-ID: <1357427402.1678.4738.camel@edumazet-glaptop>
References: <1357420764-12381-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:37679 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab3AEXKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 18:10:06 -0500
Received: by mail-pa0-f54.google.com with SMTP id bi5so9915928pad.13
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 15:10:06 -0800 (PST)
In-Reply-To: <1357420764-12381-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-05 at 16:19 -0500, Xi Wang wrote:
> The NULL pointer check `!ifa' should come before its first use.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> ---
>  net/ipv4/devinet.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index cc06a47..a8e4f26 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -823,9 +823,9 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
>  		if (!ifa) {
>  			ret = -ENOBUFS;
>  			ifa = inet_alloc_ifa();
> -			INIT_HLIST_NODE(&ifa->hash);
>  			if (!ifa)
>  				break;
> +			INIT_HLIST_NODE(&ifa->hash);
>  			if (colon)
>  				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
>  			else

Acked-by: Eric Dumazet <edumazet@google.com>

Bug origin : commit fd23c3b31107e2fc483301ee923d8a1db14e53f4
(ipv4: Add hash table of interface addresses) 

in linux-2.6.39

Thanks
