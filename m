From: Joe Perches <joe@perches.com>
Subject: irlap_frame.c: Duplicate set?
Date: Sun, 10 Jul 2011 11:43:41 -0700
Message-ID: <1310323421.3848.43.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3803 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756454Ab1GJSnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 14:43:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

frame->caddr is consecutively set to multiple values.
The first set can probably be removed.

net/irda/irlap_frame.c
[...]
void irlap_send_rd_frame(struct irlap_cb *self)
{
	struct sk_buff *tx_skb;
	struct rd_frame *frame;

	tx_skb = alloc_skb(sizeof(struct rd_frame), GFP_ATOMIC);
	if (!tx_skb)
		return;

	frame = (struct rd_frame *)skb_put(tx_skb, 2);

	frame->caddr = self->caddr;
	frame->caddr = RD_RSP | PF_BIT;

	irlap_queue_xmit(self, tx_skb);
}


