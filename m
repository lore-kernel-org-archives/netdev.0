From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/5] qla3xxx: fix: Remove unused set_multicast function.
Date: Thu, 31 Jul 2008 13:46:04 -0700
Message-ID: <12175371683630-git-send-email-ron.mercer@qlogic.com>
References: <20080731204514.GA5457@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:23911 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705AbYGaUqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 16:46:09 -0400
In-Reply-To: <20080731204514.GA5457@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device is one side of a two-function adapter (NIC and iSCSI).
Promiscuous mode setting/clearing is not allowed from the NIC side.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index bccee68..7ddb2b0 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3730,14 +3730,6 @@ static int ql3xxx_open(struct net_device *ndev)
 	return (ql_adapter_up(qdev));
 }
 
-static void ql3xxx_set_multicast_list(struct net_device *ndev)
-{
-	/*
-	 * We are manually parsing the list in the net_device structure.
-	 */
-	return;
-}
-
 static int ql3xxx_set_mac_address(struct net_device *ndev, void *p)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
@@ -4007,7 +3999,11 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	ndev->open = ql3xxx_open;
 	ndev->hard_start_xmit = ql3xxx_send;
 	ndev->stop = ql3xxx_close;
-	ndev->set_multicast_list = ql3xxx_set_multicast_list;
+	/* ndev->set_multicast_list
+	 * This device is one side of a two-function adapter
+	 * (NIC and iSCSI).  Promiscuous mode setting/clearing is
+	 * not allowed from the NIC side.
+	 */
 	SET_ETHTOOL_OPS(ndev, &ql3xxx_ethtool_ops);
 	ndev->set_mac_address = ql3xxx_set_mac_address;
 	ndev->tx_timeout = ql3xxx_tx_timeout;
-- 
1.5.0.rc4.16.g9e258

