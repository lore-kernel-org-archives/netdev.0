From: frank.blaschka@de.ibm.com
Subject: [patch 4/4] claw: convert to net_device_ops
Date: Fri, 09 Jan 2009 10:02:00 +0100
Message-ID: <20090109090222.647717000@de.ibm.com>
References: <20090109090156.422658000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:35251 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741AbZAIJCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 04:02:25 -0500
Content-Disposition: inline; filename=claw_devops.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

claw convert to net_device_ops.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com
---
 drivers/s390/net/claw.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

Index: git_linus/drivers/s390/net/claw.c
===================================================================
--- git_linus.orig/drivers/s390/net/claw.c
+++ git_linus/drivers/s390/net/claw.c
@@ -2816,22 +2816,26 @@ claw_free_netdevice(struct net_device * 
  * Initialize everything of the net device except the name and the
  * channel structs.
  */
+static struct net_device_ops claw_netdev_ops = {
+	.ndo_open		= claw_open,
+	.ndo_stop		= claw_release,
+	.ndo_get_stats		= claw_stats,
+	.ndo_start_xmit		= claw_tx,
+	.ndo_change_mtu		= claw_change_mtu,
+};
+
 static void
 claw_init_netdevice(struct net_device * dev)
 {
 	CLAW_DBF_TEXT(2, setup, "init_dev");
 	CLAW_DBF_TEXT_(2, setup, "%s", dev->name);
 	dev->mtu = CLAW_DEFAULT_MTU_SIZE;
-	dev->hard_start_xmit = claw_tx;
-	dev->open = claw_open;
-	dev->stop = claw_release;
-	dev->get_stats = claw_stats;
-	dev->change_mtu = claw_change_mtu;
 	dev->hard_header_len = 0;
 	dev->addr_len = 0;
 	dev->type = ARPHRD_SLIP;
 	dev->tx_queue_len = 1300;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
+	dev->netdev_ops = &claw_netdev_ops;
 	CLAW_DBF_TEXT(2, setup, "initok");
 	return;
 }

-- 
