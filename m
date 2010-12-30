From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4] Gemini: Gigabit ethernet driver
Date: Thu, 30 Dec 2010 01:19:57 -0800
Message-ID: <1293700797.2400.13.camel@Joe-Laptop>
References: <20101230083905.5A8EB13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	gemini-board-dev@lists.berlios.de, netdev@vger.kernel.org,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2876 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291Ab0L3JT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 04:19:59 -0500
In-Reply-To: <20101230083905.5A8EB13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-30 at 09:39 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Driver for SL351x (Gemini) SoC ethernet peripheral. Based in part
> on work by Paulius Zaleckas and GPLd code from Raidsonic and other
> NAS vendors.
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> diff --git a/drivers/net/sl351x.c b/drivers/net/sl351x.c

Output trivia:

> +static void gmac_tx_interrupt(struct net_device *dev, unsigned txq_n=
um)
[]
> +	netif_info(gmac, tx_done, dev, "txirq%u: %u,%u,%u\n",
> +		txq_num, txq->cptr, GET_RPTR(ptr_reg), GET_WPTR(ptr_reg));

pointers as decimal?
There seems to be a lot of output using %u where I expected %08x.

> +static int gmac_start_xmit(struct sk_buff *skb, struct net_device *d=
ev)
[]
> +	netif_info(gmac, tx_queued, dev, "txq%u: %u,%u,%u ? %p (%u @ %p) /%=
u\n",
> +		txq_num, txq->cptr, GET_RPTR(ptr_reg), GET_WPTR(ptr_reg),
> +		skb, skb->len, skb->data, skb_shinfo(skb)->gso_size);
[]
> +	netif_info(gmac, tx_queued, dev, "txq%u: %u,%u,%u + %p\n",
> +		txq_num, txq->cptr, GET_RPTR(ptr_reg), w, skb);
[]
> +static unsigned gmac_rx(struct net_device *dev, unsigned budget)
[]
> +	netif_info(gmac, rx_status, dev, "rxq: %u,%u\n",
> +		 GET_RPTR(ptr_reg), GET_WPTR(ptr_reg));

etc...

