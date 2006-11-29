From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] lockdep: fix sk->sk_callback_lock locking
Date: Wed, 29 Nov 2006 18:49:24 +1100
Message-ID: <E1GpKC4-0005Vc-00@gondolin.me.apana.org.au>
References: <1164715642.6588.58.camel@twins>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org, mingo@elte.hu,
	gandalf@wlug.westbo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53010 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S966031AbWK2Htv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 02:49:51 -0500
To: a.p.zijlstra@chello.nl (Peter Zijlstra)
In-Reply-To: <1164715642.6588.58.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> =========================================================
> [ INFO: possible irq lock inversion dependency detected ]
> 2.6.19-rc6 #4
> ---------------------------------------------------------
> nc/1854 just changed the state of lock:
> (af_callback_keys + sk->sk_family#2){-.-?}, at: [<c0268a7f>] sock_def_error_report+0x1f/0x90
> but this lock was taken by another, soft-irq-safe lock in the past:
> (slock-AF_INET){-+..}
> 
> and interrupts could create inverse lock ordering between them.

I think this is bogus.  The slock is not a standard lock.  When we
hold it in process context we don't actually hold the spin lock part
of it.  However, it does prevent the softirq path from running in
critical sections which also prevents any attempt to grab the
callback lock from softirq context.

If you still think there is a problem, please show an actual scenario
where it dead locks.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
