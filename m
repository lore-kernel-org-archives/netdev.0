From: Dave Jones <davej@redhat.com>
Subject: Fix build failure with 'make mandocs'.
Date: Mon, 21 Jul 2008 16:52:29 -0400
Message-ID: <20080721205229.GA26812@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753058AbYGUWBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 18:01:54 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m6LM1sKC025946
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 18:01:54 -0400
Received: from file.rdu.redhat.com (file.rdu.redhat.com [10.11.255.147])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m6LM1q5t016816
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 18:01:53 -0400
Received: from gelk.kernelslacker.org (vpn-12-131.rdu.redhat.com [10.11.12.131])
	by file.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id m6LM1pB9021530
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 18:01:52 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.2/8.14.2) with ESMTP id m6LKrUKe027168
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 16:53:30 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.2/8.14.2/Submit) id m6LKqTiP026969
	for netdev@vger.kernel.org; Mon, 21 Jul 2008 16:52:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function header comments have to go with the functions
they are documenting, or things go horribly wrong when we
try to process them with the docbook tools.

Warning(include/linux/netdevice.h:1006): No description found for parameter 'dev_queue'
Warning(include/linux/netdevice.h:1033): No description found for parameter 'dev_queue'
Warning(include/linux/netdevice.h:1067): No description found for parameter 'dev_queue'
Warning(include/linux/netdevice.h:1093): No description found for parameter 'dev_queue'
Warning(include/linux/netdevice.h:1474): No description found for parameter 'txq'
Error(net/core/dev.c:1674): cannot understand prototype: 'u32 simple_tx_hashrnd; '

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6.26.noarch/net/core/dev.c~	2008-07-21 16:49:10.000000000 -0400
+++ linux-2.6.26.noarch/net/core/dev.c	2008-07-21 16:49:47.000000000 -0400
@@ -1645,32 +1645,6 @@ out_kfree_skb:
 	return 0;
 }
 
-/**
- *	dev_queue_xmit - transmit a buffer
- *	@skb: buffer to transmit
- *
- *	Queue a buffer for transmission to a network device. The caller must
- *	have set the device and priority and built the buffer before calling
- *	this function. The function can be called from an interrupt.
- *
- *	A negative errno code is returned on a failure. A success does not
- *	guarantee the frame will be transmitted as it may be dropped due
- *	to congestion or traffic shaping.
- *
- * -----------------------------------------------------------------------------------
- *      I notice this method can also return errors from the queue disciplines,
- *      including NET_XMIT_DROP, which is a positive value.  So, errors can also
- *      be positive.
- *
- *      Regardless of the return value, the skb is consumed, so it is currently
- *      difficult to retry a send to this method.  (You can bump the ref count
- *      before sending to hold a reference for retry if you are careful.)
- *
- *      When calling this method, interrupts MUST be enabled.  This is because
- *      the BH enable code must have IRQs enabled so that it will not deadlock.
- *          --BLG
- */
-
 static u32 simple_tx_hashrnd;
 static int simple_tx_hashrnd_initialized = 0;
 
@@ -1738,6 +1712,31 @@ static struct netdev_queue *dev_pick_tx(
 	return netdev_get_tx_queue(dev, queue_index);
 }
 
+/**
+ *	dev_queue_xmit - transmit a buffer
+ *	@skb: buffer to transmit
+ *
+ *	Queue a buffer for transmission to a network device. The caller must
+ *	have set the device and priority and built the buffer before calling
+ *	this function. The function can be called from an interrupt.
+ *
+ *	A negative errno code is returned on a failure. A success does not
+ *	guarantee the frame will be transmitted as it may be dropped due
+ *	to congestion or traffic shaping.
+ *
+ * -----------------------------------------------------------------------------------
+ *      I notice this method can also return errors from the queue disciplines,
+ *      including NET_XMIT_DROP, which is a positive value.  So, errors can also
+ *      be positive.
+ *
+ *      Regardless of the return value, the skb is consumed, so it is currently
+ *      difficult to retry a send to this method.  (You can bump the ref count
+ *      before sending to hold a reference for retry if you are careful.)
+ *
+ *      When calling this method, interrupts MUST be enabled.  This is because
+ *      the BH enable code must have IRQs enabled so that it will not deadlock.
+ *          --BLG
+ */
 int dev_queue_xmit(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
--- linux-2.6.26.noarch/include/linux/netdevice.h~	2008-07-21 16:46:36.000000000 -0400
+++ linux-2.6.26.noarch/include/linux/netdevice.h	2008-07-21 16:48:53.000000000 -0400
@@ -996,17 +996,17 @@ static inline void netif_tx_schedule_all
 		netif_schedule_queue(netdev_get_tx_queue(dev, i));
 }
 
+static inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
+{
+	clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+}
+
 /**
  *	netif_start_queue - allow transmit
  *	@dev: network device
  *
  *	Allow upper layers to call the device hard_start_xmit routine.
  */
-static inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
-{
-	clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
-}
-
 static inline void netif_start_queue(struct net_device *dev)
 {
 	netif_tx_start_queue(netdev_get_tx_queue(dev, 0));
@@ -1022,13 +1022,6 @@ static inline void netif_tx_start_all_qu
 	}
 }
 
-/**
- *	netif_wake_queue - restart transmit
- *	@dev: network device
- *
- *	Allow upper layers to call the device hard_start_xmit routine.
- *	Used for flow control when transmit resources are available.
- */
 static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
 {
 #ifdef CONFIG_NETPOLL_TRAP
@@ -1041,6 +1034,13 @@ static inline void netif_tx_wake_queue(s
 		__netif_schedule(dev_queue->qdisc);
 }
 
+/**
+ *	netif_wake_queue - restart transmit
+ *	@dev: network device
+ *
+ *	Allow upper layers to call the device hard_start_xmit routine.
+ *	Used for flow control when transmit resources are available.
+ */
 static inline void netif_wake_queue(struct net_device *dev)
 {
 	netif_tx_wake_queue(netdev_get_tx_queue(dev, 0));
@@ -1056,6 +1056,11 @@ static inline void netif_tx_wake_all_que
 	}
 }
 
+static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
+{
+	set_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+}
+
 /**
  *	netif_stop_queue - stop transmitted packets
  *	@dev: network device
@@ -1063,11 +1068,6 @@ static inline void netif_tx_wake_all_que
  *	Stop upper layers calling the device hard_start_xmit routine.
  *	Used for flow control when transmit resources are unavailable.
  */
-static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
-{
-	set_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
-}
-
 static inline void netif_stop_queue(struct net_device *dev)
 {
 	netif_tx_stop_queue(netdev_get_tx_queue(dev, 0));
@@ -1083,17 +1083,17 @@ static inline void netif_tx_stop_all_que
 	}
 }
 
+static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
+{
+	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+}
+
 /**
  *	netif_queue_stopped - test if transmit queue is flowblocked
  *	@dev: network device
  *
  *	Test if transmit queue on device is currently unable to send.
  */
-static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
-{
-	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
-}
-
 static inline int netif_queue_stopped(const struct net_device *dev)
 {
 	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, 0));
@@ -1463,13 +1463,6 @@ static inline void netif_rx_complete(str
 	local_irq_restore(flags);
 }
 
-/**
- *	netif_tx_lock - grab network device transmit lock
- *	@dev: network device
- *	@cpu: cpu number of lock owner
- *
- * Get network device transmit lock
- */
 static inline void __netif_tx_lock(struct netdev_queue *txq, int cpu)
 {
 	spin_lock(&txq->_xmit_lock);
@@ -1482,6 +1475,13 @@ static inline void __netif_tx_lock_bh(st
 	txq->xmit_lock_owner = smp_processor_id();
 }
 
+/**
+ *	netif_tx_lock - grab network device transmit lock
+ *	@dev: network device
+ *	@cpu: cpu number of lock owner
+ *
+ * Get network device transmit lock
+ */
 static inline void netif_tx_lock(struct net_device *dev)
 {
 	int cpu = smp_processor_id();

-- 
http://www.codemonkey.org.uk
