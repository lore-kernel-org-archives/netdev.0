From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] ipv4: fix lock usage in udp_ioctl
Date: Thu, 15 Jun 2006 09:12:47 +1000
Message-ID: <E1FqeXX-0008OE-00@gondolin.me.apana.org.au>
References: <20060614194305.GB10391@osiris.ibm.com>
Cc: davem@davemloft.net, jgarzik@pobox.com, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mingo@elte.hu, fpavlic@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11784 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965007AbWFNXNz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 19:13:55 -0400
To: heiko.carstens@de.ibm.com (Heiko Carstens)
In-Reply-To: <20060614194305.GB10391@osiris.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> 
> As reported by the lock validator:
> 
> ============================
> [ BUG: illegal lock usage! ]
> ----------------------------
> illegal {in-hardirq-W} -> {hardirq-on-W} usage.
> syslogd/739 [HC0[0]:SC0[1]:HE1:SE0] takes:
> (&list->lock){++..}, at: [<002e36d6>] udp_ioctl+0x96/0x100
> {in-hardirq-W} state was registered at:
>  [<00062128>] lock_acquire+0x9c/0xc0
>  [<0036209e>] _spin_lock_irqsave+0x66/0x84
>  [<002912ce>] skb_dequeue+0x32/0xb0
>  [<00263160>] qeth_qdio_output_handler+0x3e8/0xf8c
>  [<00219fdc>] tiqdio_thinint_handler+0xde0/0x2234
>  [<0020448c>] do_adapter_IO+0x5c/0xa8
>  [<0020842c>] do_IRQ+0x13c/0x18c
>  [<000208a2>] io_no_vtime+0x16/0x1c
>  [<0001978c>] cpu_idle+0x1d0/0x20c

This is bogus.  These two locks belong to two different queues and they
never intersect.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
