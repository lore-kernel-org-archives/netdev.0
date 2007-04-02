From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 13/15] ieee1394: eth1394: hard_start_xmit is
 called in atomic context
Date: Mon, 2 Apr 2007 02:23:19 +0200 (CEST)
Message-ID: <tkrat.54342770aabe0a44@s5r6.in-berlin.de>
References: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=us-ascii
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:36830 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbXDBAXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2007 20:23:24 -0400
In-Reply-To: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Content-Disposition: INLINE
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -1525,7 +1525,6 @@ static void ether1394_complete_cb(void *
 /* Transmit a packet (called by kernel) */
 static int ether1394_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	gfp_t kmflags = in_interrupt() ? GFP_ATOMIC : GFP_KERNEL;
 	struct eth1394hdr *eth;
 	struct eth1394_priv *priv = netdev_priv(dev);
 	__be16 proto;
@@ -1541,7 +1540,7 @@ static int ether1394_tx(struct sk_buff *
 	struct eth1394_node_ref *node;
 	struct eth1394_node_info *node_info = NULL;
 
-	ptask = kmem_cache_alloc(packet_task_cache, kmflags);
+	ptask = kmem_cache_alloc(packet_task_cache, GFP_ATOMIC);
 	if (ptask == NULL) {
 		ret = -ENOMEM;
 		goto fail;
@@ -1557,7 +1556,7 @@ static int ether1394_tx(struct sk_buff *
 	}
 #endif
 
-	skb = skb_share_check(skb, kmflags);
+	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb) {
 		ret = -ENOMEM;
 		goto fail;

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/

