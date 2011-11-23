From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] corral some wayward N/A fw_version dust bunnies
Date: Tue, 22 Nov 2011 16:06:26 -0800 (PST)
Message-ID: <20111123000626.43E58290084C@tardy>
To: <netdev@vger.kernel.org>, "Francois Romieu" <romieu@fr.zoreil.com>,
	"Jon Mason" <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:7511 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab1KWAG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 19:06:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Round-up some wayward "N/A" fw_version dust bunnies as part of that
clean-up.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compiled only.

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 76ae476..97f63e1 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5393,7 +5393,6 @@ static void s2io_ethtool_gdrvinfo(struct net_device *dev,
 
 	strlcpy(info->driver, s2io_driver_name, sizeof(info->driver));
 	strlcpy(info->version, s2io_driver_version, sizeof(info->version));
-	strlcpy(info->fw_version, "", sizeof(info->fw_version));
 	strlcpy(info->bus_info, pci_name(sp->pdev), sizeof(info->bus_info));
 	info->regdump_len = XENA_REG_SPACE;
 	info->eedump_len = XENA_EEPROM_SPACE;
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f7bc310..e5a6d8e 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1405,8 +1405,9 @@ static void rtl8169_get_drvinfo(struct net_device *dev,
 	strlcpy(info->version, RTL8169_VERSION, sizeof(info->version));
 	strlcpy(info->bus_info, pci_name(tp->pci_dev), sizeof(info->bus_info));
 	BUILD_BUG_ON(sizeof(info->fw_version) < sizeof(rtl_fw->version));
-	strlcpy(info->fw_version, IS_ERR_OR_NULL(rtl_fw) ? "N/A" :
-	       rtl_fw->version, sizeof(info->fw_version));
+	if (!IS_ERR_OR_NULL(rtl_fw))
+		strlcpy(info->fw_version, rtl_fw->version,
+			sizeof(info->fw_version));
 }
 
 static int rtl8169_get_regs_len(struct net_device *dev)
