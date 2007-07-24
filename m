From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] kernel-doc fixes for net/
Date: Mon, 23 Jul 2007 21:42:19 -0700
Message-ID: <20070723214219.b50a0d1b.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17875 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbXGXEiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 00:38:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kernel-doc omissions in net/:

Warning(linux-2.6.23-rc1//net/core/dev.c:2728): No description found for parameter 'addr'
Warning(linux-2.6.23-rc1//net/core/dev.c:2752): No description found for parameter 'addr'
Warning(linux-2.6.23-rc1//net/core/dev.c:3839): No description found for parameter 'net_dma'
Warning(linux-2.6.23-rc1//net/core/dev.c:3877): No description found for parameter 'state'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/core/dev.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

--- linux-2.6.23-rc1.orig/net/core/dev.c
+++ linux-2.6.23-rc1/net/core/dev.c
@@ -2718,9 +2718,11 @@ int __dev_addr_add(struct dev_addr_list 
 /**
  *	dev_unicast_delete	- Release secondary unicast address.
  *	@dev: device
+ *	@addr: address to delete
+ *	@alen: length of @addr
  *
  *	Release reference to a secondary unicast address and remove it
- *	from the device if the reference count drop to zero.
+ *	from the device if the reference count drops to zero.
  *
  * 	The caller must hold the rtnl_mutex.
  */
@@ -2742,6 +2744,8 @@ EXPORT_SYMBOL(dev_unicast_delete);
 /**
  *	dev_unicast_add		- add a secondary unicast address
  *	@dev: device
+ *	@addr: address to delete
+ *	@alen: length of @addr
  *
  *	Add a secondary unicast address to the device or increase
  *	the reference count if it already exists.
@@ -3830,9 +3834,11 @@ static int dev_cpu_callback(struct notif
 
 #ifdef CONFIG_NET_DMA
 /**
- * net_dma_rebalance -
- * This is called when the number of channels allocated to the net_dma_client
- * changes.  The net_dma_client tries to have one DMA channel per CPU.
+ * net_dma_rebalance - try to maintain one DMA channel per CPU
+ * @net_dma: DMA client and associated data (lock, channels, channel_mask)
+ *
+ * This is called when the number of channels allocated to the net_dma client
+ * changes.  The net_dma client tries to have one DMA channel per CPU.
  */
 
 static void net_dma_rebalance(struct net_dma *net_dma)
@@ -3869,7 +3875,7 @@ static void net_dma_rebalance(struct net
  * netdev_dma_event - event callback for the net_dma_client
  * @client: should always be net_dma_client
  * @chan: DMA channel for the event
- * @event: event type
+ * @state: DMA state to be handled
  */
 static enum dma_state_client
 netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
