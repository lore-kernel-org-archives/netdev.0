From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: Remove some pointless conditionals before kfree_skb()
Date: Tue, 24 Feb 2009 17:33:37 +0800
Message-ID: <49A3BEF1.4030802@cn.fujitsu.com>
References: <49A3A59D.9090102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59042 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752881AbZBXJcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 04:32:12 -0500
In-Reply-To: <49A3A59D.9090102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun wrote:
> Remove some pointless conditionals before kfree_skb().
> 
> The semantic match that finds the problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @@
> expression E;
> @@
> - if (E)
> - 	kfree_skb(E);
> + kfree_skb(E);
> // </smpl>

I think kfree_skb() suppose that you have handled NULL pointer 
because it uses `unlikely` to check the pointer.
So I don't think these conditions are pointless...
 437 void kfree_skb(struct sk_buff *skb)
 438 {
 439         if (unlikely(!skb))
 440                 return;



> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> ---
>  net/ipv6/ipv6_sockglue.c |    3 +--
>  net/ipv6/tcp_ipv6.c      |    6 ++----
>  2 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 40f3246..d31df0f 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -218,8 +218,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
>  			if (opt)
>  				sock_kfree_s(sk, opt, opt->tot_len);
>  			pktopt = xchg(&np->pktoptions, NULL);
> -			if (pktopt)
> -				kfree_skb(pktopt);
> +			kfree_skb(pktopt);
>  
>  			sk->sk_destruct = inet_sock_destruct;
>  			/*
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index e5b85d4..273a5dd 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -533,8 +533,7 @@ static inline void syn_flood_warning(struct sk_buff *skb)
>  
>  static void tcp_v6_reqsk_destructor(struct request_sock *req)
>  {
> -	if (inet6_rsk(req)->pktopts)
> -		kfree_skb(inet6_rsk(req)->pktopts);
> +	kfree_skb(inet6_rsk(req)->pktopts);
>  }
>  
>  #ifdef CONFIG_TCP_MD5SIG
> @@ -1611,8 +1610,7 @@ ipv6_pktoptions:
>  		}
>  	}
>  
> -	if (opt_skb)
> -		kfree_skb(opt_skb);
> +	kfree_skb(opt_skb);
>  	return 0;
>  }
>  


-- 
Regards
Yang Hongyang
