From: frank.blaschka@de.ibm.com
Subject: [patch 10/11] qeth: layer 2 allow ethtool to set TSO
Date: Thu, 24 Apr 2008 10:15:27 +0200
Message-ID: <20080424081908.864640000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:11082 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbYDXITL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:11 -0400
Content-Disposition: inline; filename=709-qeth-ethtool.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Allow ethtool to turn on/off EDDP via ethtool TSO interface.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2008-04-23 17:55:52.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2008-04-23 17:55:54.000000000 +0200
@@ -849,6 +849,22 @@ static void qeth_l2_remove_device(struct
 	return;
 }
 
+static int qeth_l2_ethtool_set_tso(struct net_device *dev, u32 data)
+{
+	struct qeth_card *card = netdev_priv(dev);
+
+	if (data) {
+		if (card->options.large_send == QETH_LARGE_SEND_NO) {
+			card->options.large_send = QETH_LARGE_SEND_EDDP;
+			dev->features |= NETIF_F_TSO;
+		}
+	} else {
+		dev->features &= ~NETIF_F_TSO;
+		card->options.large_send = QETH_LARGE_SEND_NO;
+	}
+	return 0;
+}
+
 static struct ethtool_ops qeth_l2_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_tx_csum = ethtool_op_get_tx_csum,
@@ -856,7 +872,7 @@ static struct ethtool_ops qeth_l2_ethtoo
 	.get_sg = ethtool_op_get_sg,
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = ethtool_op_get_tso,
-	.set_tso = ethtool_op_set_tso,
+	.set_tso = qeth_l2_ethtool_set_tso,
 	.get_strings = qeth_core_get_strings,
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
 	.get_stats_count = qeth_core_get_stats_count,

-- 
