From: Tom Herbert <therbert@google.com>
Subject: [PATCH v4 03/10] net: Add netdev interfaces for recording
 sends/comp
Date: Mon, 28 Nov 2011 18:32:52 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111281817340.24344@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:50885 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939Ab1K2Cc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 21:32:57 -0500
Received: by eaaa14 with SMTP id a14so133946eaa.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 18:32:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add interfaces for drivers to call for recording number of packets and
bytes at send time and transmit completion.  Also, added a function to
"reset" a queue.  These will be used by Byte Queue Limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d19f932..9b24cc7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1859,6 +1859,34 @@ static inline int netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_qu
 	return dev_queue->state & QUEUE_STATE_ANY_XOFF_OR_FROZEN;
 }
 
+static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
+					unsigned int bytes)
+{
+}
+
+static inline void netdev_sent_queue(struct net_device *dev, unsigned int bytes)
+{
+	netdev_tx_sent_queue(netdev_get_tx_queue(dev, 0), bytes);
+}
+
+static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
+					     unsigned pkts, unsigned bytes)
+{
+}
+
+static inline void netdev_completed_queue(struct net_device *dev,
+					  unsigned pkts, unsigned bytes)
+{
+	netdev_tx_completed_queue(netdev_get_tx_queue(dev, 0), pkts, bytes);
+}
+
+static inline void netdev_tx_reset_queue(struct netdev_queue *q)
+{
+}
+
+static inline void netdev_reset_queue(struct net_device *dev_queue)
+{
+	netdev_tx_reset_queue(netdev_get_tx_queue(dev_queue, 0));
 }
 
 /**
-- 
1.7.3.1
