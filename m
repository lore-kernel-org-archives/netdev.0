From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH net-next] tcp: suppress too verbose messages in tcp_send_ack()
Date: Wed, 25 Nov 2015 17:08:31 -0500
Message-ID: <f7t7fl5g2ao.fsf@aconole.bos.csb>
References: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40437 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbbKYWId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 17:08:33 -0500
In-Reply-To: <1448488250.24696.40.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 25 Nov 2015 13:50:50 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> From: Eric Dumazet <edumazet@google.com>
>
> If tcp_send_ack() can not allocate skb, we properly handle this
> and setup a timer to try later.
>
> Use __GFP_NOWARN to avoid polluting syslog in the case host is
> under memory pressure, so that pertinent messages are not lost under
> a flood of useless information.
>
> sk_gfp_atomic() can use its gfp_mask argument (all callers currently
> were using GFP_ATOMIC before this patch)
>
> Note that when tcp_transmit_skb() is called with clone_it set to false,
> we do not attempt memory allocations, so can pass a 0 gfp_mask, which
> most compilers can emit faster than a non zero value.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/sock.h    |    2 +-
>  net/ipv4/tcp_output.c |   12 +++++++-----
>  2 files changed, 8 insertions(+), 6 deletions(-)
>
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

Sorry if I'm missing something obvious here, but with a name like
sk_gfp_atomic, would it make sense to keep the GFP_ATOMIC mask as well?
Otherwise, what is the _atomic is saying?

Thanks,
Aaron
