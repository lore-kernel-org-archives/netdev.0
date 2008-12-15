From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 5/9] irda: Introduce irda_dev_alloc_skb
Date: Mon, 15 Dec 2008 02:57:34 +0100
Message-ID: <20081215015900.428084321@sortiz.org>
References: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:51313 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751707AbYLOCDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:11 -0500
Content-Disposition: inline; filename=0005-irda-Introduce-irda_dev_alloc_skb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some RX skbs are cloned and then sent back to the transmitter.
In order to avoid reallocation on that code path, we get more space from
the beginning on the RX path.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 include/net/irda/irda.h |    1 +
 net/irda/irda_device.c  |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/net/irda/irda.h b/include/net/irda/irda.h
index ce510aa..213d4c0 100644
--- a/include/net/irda/irda.h
+++ b/include/net/irda/irda.h
@@ -133,4 +133,5 @@ extern int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 			    struct net_device *orig_dev);
 
 extern struct sk_buff *irda_alloc_skb(unsigned int size, gfp_t priority);
+extern struct sk_buff *irda_dev_alloc_skb(unsigned int size);
 #endif /* NET_IRDA_H */
diff --git a/net/irda/irda_device.c b/net/irda/irda_device.c
index 5271015..62b991c 100644
--- a/net/irda/irda_device.c
+++ b/net/irda/irda_device.c
@@ -308,6 +308,18 @@ struct sk_buff *irda_alloc_skb(unsigned int size, gfp_t priority)
 }
 EXPORT_SYMBOL(irda_alloc_skb);
 
+struct sk_buff *irda_dev_alloc_skb(unsigned int size)
+{
+	struct sk_buff *skb;
+
+	skb = dev_alloc_skb(size + sizeof(struct irda_skb_cb));
+	if (likely(skb))
+		skb_reserve(skb, sizeof(struct irda_skb_cb));
+
+	return skb;
+}
+EXPORT_SYMBOL(irda_dev_alloc_skb);
+
 #ifdef CONFIG_ISA_DMA_API
 /*
  * Function setup_dma (idev, buffer, count, mode)
-- 
1.6.0.4.766.g6fc4a.dirty

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
