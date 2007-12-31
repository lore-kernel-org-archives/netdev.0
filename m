From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [CORE]: adding memory accounting points
Date: Sun, 30 Dec 2007 23:58:06 -0800 (PST)
Message-ID: <20071230.235806.171376126.davem@davemloft.net>
References: <47775B25.7020401@redhat.com>
	<47775C20.5010004@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753544AbXLaH6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 02:58:07 -0500
In-Reply-To: <47775C20.5010004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hideo AOKI <haoki@redhat.com>
Date: Sun, 30 Dec 2007 03:51:44 -0500

> To consolidate memory accounting functions, this patch adds memory
> accounting calls to network core functions. Moreover, present
> memory accounting call is renamed to new accounting call.
> 
> Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
> Cc: Masami Hiramatsu <mhiramat@redhat.com>
> signed-off-by: Takahiro Yasui <tyasui@redhat.com>
> signed-off-by: Hideo Aoki <haoki@redhat.com>

This patch would not apply, because is contained changes
present in the first patch, specifically:

> diff -pruN net-2.6.25-t12t19m-p1/include/net/sock.h net-2.6.25-t12t19m-p2/include/net/sock.h
> --- net-2.6.25-t12t19m-p1/include/net/sock.h	2007-12-29 20:16:31.000000000 -0500
> +++ net-2.6.25-t12t19m-p2/include/net/sock.h	2007-12-29 20:28:15.000000000 -0500
> @@ -1116,7 +1116,7 @@ static inline int skb_copy_to_page(struc
>  	skb->data_len	     += copy;
>  	skb->truesize	     += copy;
>  	sk->sk_wmem_queued   += copy;
> -	sk->sk_forward_alloc -= copy;
> +	sk_mem_charge(sk, copy);
>  	return 0;
>  }
> 
> @@ -1142,6 +1142,7 @@ static inline void skb_set_owner_r(struc
>  	skb->sk = sk;
>  	skb->destructor = sock_rfree;
>  	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
> +	sk_mem_charge(sk, skb->truesize);
>  }
> 
>  extern void sk_reset_timer(struct sock *sk, struct timer_list* timer,

And now I see exactly what you did, and it is quite careless.

You wrote one big patch then tried to split it up by hand.  This
proves to me that you did not test the patches individually.  Even
worse, you did not even try to apply each patch nor compile the tree
each step along the way as a basic sanity check.

This wastes a lot of my time, as well as the time of other developers
who might want to try out and test your changes.

I will fix it up this time, but please do not ever do this again.
