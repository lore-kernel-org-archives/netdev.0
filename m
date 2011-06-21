From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 1/7] netdev: add standardized irq naming function
Date: Tue, 21 Jun 2011 10:05:42 -0700
Message-ID: <20110621170658.395370414@vyatta.com>
References: <20110621170541.309890798@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49488 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756961Ab1FURHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:07:23 -0400
Content-Disposition: inline; filename=netdev-irq-name.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To force driver developers to use a standard convention for naming
network device IRQ's, provide a standardized method for creating
the name.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/include/linux/netdevice.h	2011-06-21 08:58:32.207953328 -0700
+++ b/include/linux/netdevice.h	2011-06-21 09:12:12.155952869 -0700
@@ -2631,6 +2631,46 @@ static inline const char *netdev_name(co
 	return dev->name;
 }
 
+/* function bits for netdev_irqname */
+#define NETIF_IRQ_TX	1
+#define NETIF_IRQ_RX	2
+#define NETIF_IRQ_TXRX	3
+#define NETIF_IRQ_OTHER 0	/* none of the above */
+
+/**
+ *	netdev_irqname - generate name for irq
+ *	@buf: space to store result
+ *	@buflen: sizeof buf
+ *	@dev: network device
+ *	@queue: assoctiated network queue
+ *	@function: function of irq
+ *
+ * Format a IRQ name according to standard convention to be passed
+ * to request_irq().
+ */
+static inline const char *netdev_irqname(char *buf, size_t buflen,
+					 const struct net_device *dev,
+					 unsigned queue,
+					 unsigned function)
+{
+	switch (function) {
+	case NETIF_IRQ_TX:
+		snprintf(buf, buflen, "%s-tx-%u", dev->name, queue);
+		break;
+	case NETIF_IRQ_RX:
+		snprintf(buf, buflen, "%s-rx-%u", dev->name, queue);
+		break;
+	case NETIF_IRQ_TXRX:
+		snprintf(buf, buflen, "%s-%u", dev->name, queue);
+		break;
+	default:
+		snprintf(buf, buflen, "%s", dev->name);
+	}
+
+	return buf;
+}
+
+
 extern int netdev_printk(const char *level, const struct net_device *dev,
 			 const char *format, ...)
 	__attribute__ ((format (printf, 3, 4)));


