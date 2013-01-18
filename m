From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: Fix addrconf_dst_alloc() failure check.
Date: Fri, 18 Jan 2013 06:28:34 -0800
Message-ID: <1358519314.11051.111.camel@edumazet-glaptop>
References: <50F93879.6010201@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:52872 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387Ab3ARO2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 09:28:37 -0500
Received: by mail-pb0-f50.google.com with SMTP id wz7so2083410pbc.9
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2013 06:28:37 -0800 (PST)
In-Reply-To: <50F93879.6010201@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-18 at 20:56 +0900, YOSHIFUJI Hideaki wrote:
> The function returns NULL on error and it never return error code
> embedded in pointer.
> 

Which functions returns NULL ?

addrconf_dst_alloc() returns ERR_PTR(-ENOMEM) in case of error in my net
tree.

Also, please consider adding the bug origin in your changelogs.

Thanks !

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/ipv6/addrconf.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 420e563..d0a2df2b 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -783,8 +783,8 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
>  	}
>  
>  	rt = addrconf_dst_alloc(idev, addr, false);
> -	if (IS_ERR(rt)) {
> -		err = PTR_ERR(rt);
> +	if (!rt) {
> +		err = -ENOMEM;
>  		goto out;
>  	}
>  
