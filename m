From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC net-next 11/11] firewire net: Release broadcast/fifo resources
 on ifdown.
Date: Fri, 08 Mar 2013 10:45:57 +0900
Message-ID: <513942D5.8050404@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanr@s5r6.in-berlin.de, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39305 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752249Ab3CHBp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 20:45:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since those resources are allocated on ifup, relsase them on ifdown.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index ca41446..c1898ad 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1295,9 +1295,12 @@ out:
 /* ifdown */
 static int fwnet_stop(struct net_device *net)
 {
+	struct fwnet_device *dev = netdev_priv(net);
+
 	netif_stop_queue(net);
 
-	/* Deallocate iso context for use by other applications? */
+	fwnet_broadcast_stop(dev);
+	fwnet_fifo_stop(dev);
 
 	return 0;
 }
@@ -1638,9 +1641,6 @@ static int fwnet_remove(struct device *_dev)
 	if (list_empty(&dev->peer_list)) {
 		unregister_netdev(net);
 
-		fwnet_fifo_stop(dev);
-		fwnet_broadcast_stop(dev);
-
 		for (i = 0; dev->queued_datagrams && i < 5; i++)
 			ssleep(1);
 		WARN_ON(dev->queued_datagrams);
-- 
1.7.9.5
