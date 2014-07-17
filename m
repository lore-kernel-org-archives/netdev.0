From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 01/14] be2net: use -ENETDOWN error status when interface is down
Date: Thu, 17 Jul 2014 16:20:19 +0530
Message-ID: <1405594232-30818-2-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9070 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756773AbaGQKsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:33 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Updating VF's tx-rate and FW-download are not allowed when the interface is
down. In such cases return -ENETDOWN to the stack.
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6297e72..db5fb51 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1372,7 +1372,7 @@ static int be_set_vf_tx_rate(struct net_device *netdev, int vf,
 
 	if (!link_status) {
 		dev_err(dev, "TX-rate setting not allowed when link is down\n");
-		status = -EPERM;
+		status = -ENETDOWN;
 		goto err;
 	}
 
@@ -4221,7 +4221,7 @@ int be_load_fw(struct be_adapter *adapter, u8 *fw_file)
 	if (!netif_running(adapter->netdev)) {
 		dev_err(&adapter->pdev->dev,
 			"Firmware load not allowed (interface is down)\n");
-		return -1;
+		return -ENETDOWN;
 	}
 
 	status = request_firmware(&fw, fw_file, &adapter->pdev->dev);
-- 
1.7.1
