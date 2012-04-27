From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 1/3] be2net: Ignore status of some ioctls during
 driver load
Date: Thu, 26 Apr 2012 20:42:31 -0500
Message-ID: <20120427014231.GA721@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:56116 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757840Ab2D0Bmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 21:42:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   17 ++++-------------
 1 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c9f757c..c8f7b3a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2704,24 +2704,15 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, NULL);
 
-	status = be_vid_config(adapter, false, 0);
-	if (status)
-		goto err;
+	be_vid_config(adapter, false, 0);
 
 	be_set_rx_mode(adapter->netdev);
 
-	status = be_cmd_get_flow_control(adapter, &tx_fc, &rx_fc);
-	/* For Lancer: It is legal for this cmd to fail on VF */
-	if (status && (be_physfn(adapter) || !lancer_chip(adapter)))
-		goto err;
+	be_cmd_get_flow_control(adapter, &tx_fc, &rx_fc);
 
-	if (rx_fc != adapter->rx_fc || tx_fc != adapter->tx_fc) {
-		status = be_cmd_set_flow_control(adapter, adapter->tx_fc,
+	if (rx_fc != adapter->rx_fc || tx_fc != adapter->tx_fc)
+		be_cmd_set_flow_control(adapter, adapter->tx_fc,
 					adapter->rx_fc);
-		/* For Lancer: It is legal for this cmd to fail on VF */
-		if (status && (be_physfn(adapter) || !lancer_chip(adapter)))
-			goto err;
-	}
 
 	pcie_set_readrq(adapter->pdev, 4096);
 
-- 
1.7.5.4
