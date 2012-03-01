From: Cloud Ren <cjren@qca.qualcomm.com>
Subject: [PATCH 1/3] atl1c: remove ATL1C_DRV_VERSION stuff
Date: Thu, 1 Mar 2012 13:41:07 +0800
Message-ID: <1330580469-23348-2-git-send-email-cjren@qca.qualcomm.com>
References: <1330580469-23348-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	Cloud Ren <cjren@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:41011 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826Ab2CAFlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 00:41:39 -0500
In-Reply-To: <1330580469-23348-1-git-send-email-cjren@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The version is reflected by the kernel release, driver versions upstream make no
sense.

Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h         |    1 -
 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c |    2 --
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    5 -----
 3 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index ca70e16..b24f1ce 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -628,7 +628,6 @@ struct atl1c_adapter {
 		readl(((a)->hw_addr + reg) + ((offset) << 2)))
 
 extern char atl1c_driver_name[];
-extern char atl1c_driver_version[];
 
 extern void atl1c_reinit_locked(struct atl1c_adapter *adapter);
 extern s32 atl1c_reset_hw(struct atl1c_hw *hw);
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
index 0a9326a..8826f56 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
@@ -230,8 +230,6 @@ static void atl1c_get_drvinfo(struct net_device *netdev,
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
 	strlcpy(drvinfo->driver,  atl1c_driver_name, sizeof(drvinfo->driver));
-	strlcpy(drvinfo->version, atl1c_driver_version,
-		sizeof(drvinfo->version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = 0;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 0f21a9b..6bf387b 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -21,9 +21,7 @@
 
 #include "atl1c.h"
 
-#define ATL1C_DRV_VERSION "1.0.1.0-NAPI"
 char atl1c_driver_name[] = "atl1c";
-char atl1c_driver_version[] = ATL1C_DRV_VERSION;
 #define PCI_DEVICE_ID_ATTANSIC_L2C      0x1062
 #define PCI_DEVICE_ID_ATTANSIC_L1C      0x1063
 #define PCI_DEVICE_ID_ATHEROS_L2C_B	0x2060 /* AR8152 v1.1 Fast 10/100 */
@@ -57,7 +55,6 @@ MODULE_DEVICE_TABLE(pci, atl1c_pci_tbl);
 MODULE_AUTHOR("Jie Yang <jie.yang@atheros.com>");
 MODULE_DESCRIPTION("Atheros 1000M Ethernet Network Driver");
 MODULE_LICENSE("GPL");
-MODULE_VERSION(ATL1C_DRV_VERSION);
 
 static int atl1c_stop_mac(struct atl1c_hw *hw);
 static void atl1c_enable_rx_ctrl(struct atl1c_hw *hw);
@@ -2761,8 +2758,6 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 		goto err_register;
 	}
 
-	if (netif_msg_probe(adapter))
-		dev_info(&pdev->dev, "version %s\n", ATL1C_DRV_VERSION);
 	cards_found++;
 	return 0;
 
-- 
1.7.7
