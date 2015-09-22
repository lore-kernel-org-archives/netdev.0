From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 20/33] arcnet: Add arcnet_<I/O> macros
Date: Tue, 22 Sep 2015 11:02:01 +0200
Message-ID: <1442912534-10821-21-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52043 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932634AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

arcnet uses an I/O scheme which can align I/O addresses to word boundaries
on different architectures.

Add arcnet specific macros which can hide this alignment calculation.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcdevice.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index 9ca135d..95e7ed6 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -342,5 +342,30 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 			       struct net_device *dev);
 void arcnet_timeout(struct net_device *dev);
 
+/* I/O equivalents */
+
+/* addr and offset allow register like names to define the actual IO  address.
+ * A configuration option multiplies the offset for alignment.
+ */
+#define arcnet_inb(addr, offset)					\
+	inb((addr) + (offset))
+#define arcnet_outb(value, addr, offset)				\
+	outb(value, (addr) + (offset))
+
+#define arcnet_insb(addr, offset, buffer, count)			\
+	insb((addr) + (offset), buffer, count)
+#define arcnet_outsb(addr, offset, buffer, count)			\
+	outsb((addr) + (offset), buffer, count)
+
+#define arcnet_inw(addr, offset)					\
+	inw((addr) + (offset))
+#define arcnet_outw(value, addr, offset)				\
+	outw(value, (addr) + (offset))
+
+#define arcnet_insw(addr, offset, buffer, count)			\
+	insw((addr) + (offset), buffer, count)
+#define arcnet_outsw(addr, offset, buffer, count)			\
+	outsw((addr) + (offset), buffer, count)
+
 #endif				/* __KERNEL__ */
 #endif				/* _LINUX_ARCDEVICE_H */
-- 
2.5.1
