From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 7/9] irda: Stack RX path callers should use irda_dev_alloc_skb
Date: Mon, 15 Dec 2008 02:57:36 +0100
Message-ID: <20081215015902.740698225@sortiz.org>
References: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:44683 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751778AbYLOCDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:13 -0500
Content-Disposition: inline; filename=0007-irda-Stack-RX-path-callers-should-use-irda_dev_allo.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/irttp.c   |    2 +-
 net/irda/wrapper.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 4b913de..6f28186 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -241,7 +241,7 @@ static struct sk_buff *irttp_reassemble_skb(struct tsap_cb *self)
 	IRDA_DEBUG(2, "%s(), self->rx_sdu_size=%d\n", __func__,
 		   self->rx_sdu_size);
 
-	skb = dev_alloc_skb(TTP_HEADER + self->rx_sdu_size);
+	skb = irda_dev_alloc_skb(TTP_HEADER + self->rx_sdu_size);
 	if (!skb)
 		return NULL;
 
diff --git a/net/irda/wrapper.c b/net/irda/wrapper.c
index b13cb3b..e1ab6d1 100644
--- a/net/irda/wrapper.c
+++ b/net/irda/wrapper.c
@@ -225,7 +225,8 @@ async_bump(struct net_device *dev,
 		  (rx_buff->len < IRDA_RX_COPY_THRESHOLD));
 
 	/* Allocate a new skb */
-	newskb = dev_alloc_skb(docopy ? rx_buff->len + 1 : rx_buff->truesize);
+	newskb = irda_dev_alloc_skb(docopy ?
+				    rx_buff->len + 1 : rx_buff->truesize);
 	if (!newskb)  {
 		stats->rx_dropped++;
 		/* We could deliver the current skb if doing ZeroCopy Rx,
-- 
1.6.0.4.766.g6fc4a.dirty

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
