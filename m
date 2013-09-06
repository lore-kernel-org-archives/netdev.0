From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH net-next v2] net: add documentation for BQL helpers
Date: Fri, 6 Sep 2013 16:58:00 +0100
Message-ID: <1378483080-31632-1-git-send-email-f.fainelli@gmail.com>
References: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2771 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005Ab3IFP6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 11:58:13 -0400
In-Reply-To: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com>
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
Change since v1:
- incorporate suggestsions from Eric Dumazet and just specify the exact
  match for netdev_sent_queue/netdev_completed_queue

 include/linux/netdevice.h | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8ed4ae9..041b42a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2101,6 +2101,15 @@ static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
 #endif
 }
 
+/**
+ * 	netdev_sent_queue - report the number of bytes queued to hardware
+ * 	@dev: network device
+ * 	@bytes: number of bytes queued to the hardware device queue
+ *
+ * 	Report the number of bytes queued for sending/completion to the network
+ * 	device hardware queue. @bytes should be a good approximation and should
+ * 	exactly match netdev_completed_queue() @bytes
+ */
 static inline void netdev_sent_queue(struct net_device *dev, unsigned int bytes)
 {
 	netdev_tx_sent_queue(netdev_get_tx_queue(dev, 0), bytes);
@@ -2130,6 +2139,16 @@ static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
 #endif
 }
 
+/**
+ * 	netdev_completed_queue - report bytes and packets completed by device
+ * 	@dev: network device
+ * 	@pkts: actual number of packets sent over the medium
+ * 	@bytes: actual number of bytes sent over the medium
+ *
+ * 	Report the number of bytes and packets transmitted by the network device
+ * 	hardware queue over the physical medium, @bytes must exactly match the
+ * 	@bytes amount passed to netdev_sent_queue()
+ */
 static inline void netdev_completed_queue(struct net_device *dev,
 					  unsigned int pkts, unsigned int bytes)
 {
@@ -2144,6 +2163,13 @@ static inline void netdev_tx_reset_queue(struct netdev_queue *q)
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
