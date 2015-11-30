From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] tcp: suppress too verbose messages in
 tcp_send_ack()
Date: Mon, 30 Nov 2015 11:06:07 -0500 (EST)
Message-ID: <20151130.110607.1409128209032271059.davem@redhat.com>
References: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751652AbbK3QGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 11:06:08 -0500
In-Reply-To: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Nov 2015 13:50:50 -0800

> diff --git a/include/net/sock.h b/include/net/sock.h
> index 7f89e4ba18d1..ead514332ae8 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -776,7 +776,7 @@ static inline int sk_memalloc_socks(void)
>  
>  static inline gfp_t sk_gfp_atomic(const struct sock *sk, gfp_t gfp_mask)
>  {
> -	return GFP_ATOMIC | (sk->sk_allocation & __GFP_MEMALLOC);
> +	return gfp_mask | (sk->sk_allocation & __GFP_MEMALLOC);
>  }
>  
>  static inline void sk_acceptq_removed(struct sock *sk)

Eric, please rename this to "sk_gfp_mask()" or "sk_gfp_flags()" or
something like that since it doesn't unconditionally use GFP_ATOMIC
any more.

Otherwise I'm %100 fine with this change.

Thank you.
