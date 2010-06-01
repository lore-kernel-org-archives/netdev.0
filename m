From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ppp: eliminate shadowed variable name
Date: Tue, 1 Jun 2010 09:05:46 -0700
Message-ID: <20100601090546.79c1fca0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47463 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756171Ab0FAQFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 12:05:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse complains about shadowed declaration of skb. So use other
name.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ppp_generic.c	2010-06-01 08:49:58.859739636 -0700
+++ b/drivers/net/ppp_generic.c	2010-06-01 08:50:41.184870657 -0700
@@ -1927,9 +1927,9 @@ ppp_receive_mp_frame(struct ppp *ppp, st
 	/* If the queue is getting long, don't wait any longer for packets
 	   before the start of the queue. */
 	if (skb_queue_len(&ppp->mrq) >= PPP_MP_MAX_QLEN) {
-		struct sk_buff *skb = skb_peek(&ppp->mrq);
-		if (seq_before(ppp->minseq, skb->sequence))
-			ppp->minseq = skb->sequence;
+		struct sk_buff *mskb = skb_peek(&ppp->mrq);
+		if (seq_before(ppp->minseq, mskb->sequence))
+			ppp->minseq = mskb->sequence;
 	}
 
 	/* Pull completed packets off the queue and receive them. */
