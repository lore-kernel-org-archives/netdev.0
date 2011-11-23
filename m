From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 03/10] net: Add netdev interfaces recording send/compl
Date: Tue, 22 Nov 2011 21:52:37 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111222139560.14623@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f74.google.com ([209.85.161.74]:54794 "EHLO
	mail-fx0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab1KWFwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 00:52:40 -0500
Received: by mail-fx0-f74.google.com with SMTP id s1so38323fab.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 21:52:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add interfaces for drivers to call for recording number of packets and
bytes at send time and transmit completion.  Also, added a function to
"reset" a queue.  These will be used by Byte Queue Limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dfb50ed..8b3eb8a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1924,6 +1924,35 @@ static inline int netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_qu
 	return dev_queue->state & QUEUE_STATE_ANY_XOFF_OR_FROZEN;
 }
 
+static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
+					unsigned int pkts, unsigned int bytes)
+{
+}
+
+static inline void netdev_sent_queue(struct net_device *dev,
+				     unsigned int pkts, unsigned int bytes)
+{
+	netdev_tx_sent_queue(netdev_get_tx_queue(dev, 0), pkts, bytes);
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
