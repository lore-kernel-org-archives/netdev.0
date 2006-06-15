From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] ipv4: fix lock usage in udp_ioctl
Date: Thu, 15 Jun 2006 07:28:07 +0200
Message-ID: <20060615052806.GA19803@elte.hu>
References: <20060614194305.GB10391@osiris.ibm.com> <E1FqeXX-0008OE-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, davem@davemloft.net,
	jgarzik@pobox.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, fpavlic@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:13696 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S964922AbWFOF3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 01:29:25 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1FqeXX-0008OE-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This is bogus.  These two locks belong to two different queues and 
> they never intersect.

yeah - qeth does its own skb-queue management here, and it's done in an 
irq-safe manner.

Heiko, in qeth_main.c, could you do something like:

+ static struct lockdep_type_key qdio_out_skb_queue_key;

...
		skb_queue_head_init(&card->qdio.out_qs[i]->bufs[j].
				     skb_list);
+		lockdep_reinit_key(&card->qdio.out_qs[i]->bufs[j].skb_list,
				   &qdio_out_skb_queue_key)

	Ingo
