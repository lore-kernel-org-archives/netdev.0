From: frank.blaschka@de.ibm.com
Subject: [patch 2/4] ctcm: convert to net_device_ops
Date: Fri, 09 Jan 2009 10:01:58 +0100
Message-ID: <20090109090221.211457000@de.ibm.com>
References: <20090109090156.422658000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:35243 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655AbZAIJCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 04:02:23 -0500
Content-Disposition: inline; filename=ctcm_devops.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

ctcm convert to net_device_ops.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/ctcm_main.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

Index: git_linus/drivers/s390/net/ctcm_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/ctcm_main.c
+++ git_linus/drivers/s390/net/ctcm_main.c
@@ -1099,15 +1099,19 @@ static void ctcm_free_netdevice(struct n
 
 struct mpc_group *ctcmpc_init_mpc_group(struct ctcm_priv *priv);
 
+static struct net_device_ops ctcm_netdev_ops = {
+	.ndo_open		= ctcm_open,
+	.ndo_stop		= ctcm_close,
+	.ndo_get_stats		= ctcm_stats,
+	.ndo_change_mtu	   	= ctcm_change_mtu,
+};
+
 void static ctcm_dev_setup(struct net_device *dev)
 {
-	dev->open = ctcm_open;
-	dev->stop = ctcm_close;
-	dev->get_stats = ctcm_stats;
-	dev->change_mtu = ctcm_change_mtu;
 	dev->type = ARPHRD_SLIP;
 	dev->tx_queue_len = 100;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
+	dev->netdev_ops = &ctcm_netdev_ops;
 }
 
 /*
@@ -1157,12 +1161,12 @@ static struct net_device *ctcm_init_netd
 		dev->mtu = MPC_BUFSIZE_DEFAULT -
 				TH_HEADER_LENGTH - PDU_HEADER_LENGTH;
 
-		dev->hard_start_xmit = ctcmpc_tx;
+		ctcm_netdev_ops.ndo_start_xmit = ctcmpc_tx;
 		dev->hard_header_len = TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
 		priv->buffer_size = MPC_BUFSIZE_DEFAULT;
 	} else {
 		dev->mtu = CTCM_BUFSIZE_DEFAULT - LL_HEADER_LENGTH - 2;
-		dev->hard_start_xmit = ctcm_tx;
+		ctcm_netdev_ops.ndo_start_xmit = ctcm_tx;
 		dev->hard_header_len = LL_HEADER_LENGTH + 2;
 	}
 

-- 
