From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: add documentation for BQL helpers
Date: Fri, 6 Sep 2013 11:58:39 +0100
Message-ID: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4412 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750847Ab3IFK67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 06:58:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide a kernel-doc comment documentation for the BQL helpers:
- netdev_sent_queue
- netdev_completed_queue
- netdev_reset_queue

Similarly to how it is done for the other functions, the documentation
only covers the function operating on struct net_device and not struct
netdev_queue.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdevice.h | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8ed4ae9..ac36629 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2101,6 +2101,16 @@ static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
 #endif
 }
 
+/**
+ * 	netdev_sent_queue - report the number of bytes queued to hardware
+ * 	@dev: network device
+ * 	@bytes: number of bytes queued to the hardware device queue
+ *
+ * 	Report the number of bytes queued for sending/completion to the network
+ * 	device hardware queue. @bytes should specify the number of bytes which
+ * 	will be sent over the physical medium (without prepended/appended
+ * 	control blocks, FCS...)
+ */
 static inline void netdev_sent_queue(struct net_device *dev, unsigned int bytes)
 {
 	netdev_tx_sent_queue(netdev_get_tx_queue(dev, 0), bytes);
@@ -2130,6 +2140,16 @@ static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
 #endif
 }
 
+/**
+ * 	netdev_completed_queue - report bytes and packets completed by device
+ * 	@dev: network device
+ * 	@pkts: actual number of packets sent over the medium
+ * 	@bytes: actual number of bytes sent over the medium
+ *
+ * 	Report the number of bytes and packets transmitted by the network device
+ * 	hardware queue over the physical medium (without prepended/appended
+ * 	control blocks, FCS...)
+ */
 static inline void netdev_completed_queue(struct net_device *dev,
 					  unsigned int pkts, unsigned int bytes)
 {
@@ -2144,6 +2164,13 @@ static inline void netdev_tx_reset_queue(struct netdev_queue *q)
 #endif
 }
 
+/**
+ * 	netdev_reset_queue - reset the packets and bytes count of a network device
+ * 	@dev_queue: network device
+ *
+ * 	Reset the bytes and packet count of a network device and clear the
+ * 	software flow control OFF bit for this network device
+ */
 static inline void netdev_reset_queue(struct net_device *dev_queue)
 {
 	netdev_tx_reset_queue(netdev_get_tx_queue(dev_queue, 0));
-- 
1.8.1.2
