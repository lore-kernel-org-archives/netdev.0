From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH net-next] net: remove sk_init() helper
Date: Wed, 26 Sep 2012 10:07:42 +0800
Message-ID: <5062636E.2060200@gmail.com>
References: <1348608733.26828.3492.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35435 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab2IZCH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 22:07:59 -0400
Received: by padhz1 with SMTP id hz1so66320pad.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 19:07:58 -0700 (PDT)
In-Reply-To: <1348608733.26828.3492.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet said, at 2012/9/26 5:32:
> From: Eric Dumazet <edumazet@google.com>
> 
> It seems sk_init() has no value today and even does strange things :
> 
> # grep . /proc/sys/net/core/?mem_*
> /proc/sys/net/core/rmem_default:212992
> /proc/sys/net/core/rmem_max:131071
> /proc/sys/net/core/wmem_default:212992
> /proc/sys/net/core/wmem_max:131071
> 
> We can remove it completely.

Ye, I have reported this problem.
http://lists.openwall.net/netdev/2012/04/27/49

How about for small RAM ~16M?


> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/sock.h |    2 --
>  net/core/sock.c    |   13 -------------
>  net/socket.c       |    6 ------
>  3 files changed, 21 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 42053759..02456b6 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2229,8 +2229,6 @@ extern int net_msg_warn;
>  extern __u32 sysctl_wmem_max;
>  extern __u32 sysctl_rmem_max;
>  
> -extern void sk_init(void);
> -
>  extern int sysctl_optmem_max;
>  
>  extern __u32 sysctl_wmem_default;
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 727114c..f5a4260 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1464,19 +1464,6 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
>  }
>  EXPORT_SYMBOL_GPL(sk_setup_caps);
>  
> -void __init sk_init(void)
> -{
> -	if (totalram_pages <= 4096) {
> -		sysctl_wmem_max = 32767;
> -		sysctl_rmem_max = 32767;
> -		sysctl_wmem_default = 32767;
> -		sysctl_rmem_default = 32767;
> -	} else if (totalram_pages >= 131072) {
> -		sysctl_wmem_max = 131071;
> -		sysctl_rmem_max = 131071;
> -	}
> -}
> -
>  /*
>   *	Simple resource managers for sockets.
>   */
> diff --git a/net/socket.c b/net/socket.c
> index c641549..80dc7e8 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -2601,12 +2601,6 @@ static int __init sock_init(void)
>  		goto out;
>  
>  	/*
> -	 *      Initialize sock SLAB cache.
> -	 */
> -
> -	sk_init();
> -
> -	/*
>  	 *      Initialize skbuff SLAB cache
>  	 */
>  	skb_init();
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
