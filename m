From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: auro deadlock  (was Re: e100 lockdep irq lock inversion.)
Date: Sat, 08 Jul 2006 13:06:59 +1000
Message-ID: <E1Fz39n-0007tC-00@gondolin.me.apana.org.au>
References: <1152295989.3111.116.camel@laptopd505.fenrus.org>
Cc: davej@redhat.com, akpm@osdl.org, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:29195 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932495AbWGHDHQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 23:07:16 -0400
To: arjan@infradead.org (Arjan van de Ven)
In-Reply-To: <1152295989.3111.116.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven <arjan@infradead.org> wrote:
> 
> Act 1
> 
> Enter the mpi_start_xmit() function, which is airo's xmit function.
> This function takes the aux_lock first, with irq's off, then calls
> skb_queue_tail(). skb_queue_tail takes the sk_receive_queue.lock (with
> irqsave as well).

Nope, make that ai->txq.

> Act 2
> 
> Enter the ipcalc program. This program calls an ioctl, which ends up
> calling udp_ioctl. udp_ioctl does
>   spin_lock_bh(&sk->sk_receive_queue.lock);

Different queue.

So no deadlock.  Better luck next time :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
