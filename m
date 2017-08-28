From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 04/11] bnxt: Add PCIe device IDs for bcm58802/bcm58808
Date: Mon, 28 Aug 2017 13:40:28 -0400
Message-ID: <1503942035-24924-5-git-send-email-michael.chan@broadcom.com>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Ray Jui <ray.jui@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:38803 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751410AbdH1Rky (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:40:54 -0400
Received: by mail-qt0-f179.google.com with SMTP id w42so5223480qtg.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:40:54 -0700 (PDT)
In-Reply-To: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ray Jui <ray.jui@broadcom.com>

Add PCIe device ID for bcm58802 and bcm58808. Also add chip number
update to declare bcm588xx as chip class phase 4 and later

Signed-off-by: Ray Jui <ray.jui@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 8 +++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 8 ++++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9657bfb..500681d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -104,6 +104,8 @@ enum board_idx {
 	BCM57416_NPAR,
 	BCM57452,
 	BCM57454,
+	BCM58802,
+	BCM58808,
 	NETXTREME_E_VF,
 	NETXTREME_C_VF,
 };
@@ -140,11 +142,14 @@ enum board_idx {
 	{ "Broadcom BCM57416 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM57452 NetXtreme-E 10Gb/25Gb/40Gb/50Gb Ethernet" },
 	{ "Broadcom BCM57454 NetXtreme-E 10Gb/25Gb/40Gb/50Gb/100Gb Ethernet" },
+	{ "Broadcom BCM58802 NetXtreme-S 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM58808 NetXtreme-S 10Gb/25Gb/40Gb/50Gb/100Gb Ethernet" },
 	{ "Broadcom NetXtreme-E Ethernet Virtual Function" },
 	{ "Broadcom NetXtreme-C Ethernet Virtual Function" },
 };
 
 static const struct pci_device_id bnxt_pci_tbl[] = {
+	{ PCI_VDEVICE(BROADCOM, 0x1614), .driver_data = BCM57454 },
 	{ PCI_VDEVICE(BROADCOM, 0x16c0), .driver_data = BCM57417_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16c8), .driver_data = BCM57301 },
 	{ PCI_VDEVICE(BROADCOM, 0x16c9), .driver_data = BCM57302 },
@@ -175,8 +180,9 @@ enum board_idx {
 	{ PCI_VDEVICE(BROADCOM, 0x16ed), .driver_data = BCM57414_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16ee), .driver_data = BCM57416_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16ef), .driver_data = BCM57416_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16f0), .driver_data = BCM58808 },
 	{ PCI_VDEVICE(BROADCOM, 0x16f1), .driver_data = BCM57452 },
-	{ PCI_VDEVICE(BROADCOM, 0x1614), .driver_data = BCM57454 },
+	{ PCI_VDEVICE(BROADCOM, 0xd802), .driver_data = BCM58802 },
 #ifdef CONFIG_BNXT_SRIOV
 	{ PCI_VDEVICE(BROADCOM, 0x1606), .driver_data = NETXTREME_E_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x1609), .driver_data = NETXTREME_E_VF },
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 801c0f7..3521e46 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -990,6 +990,9 @@ struct bnxt {
 
 #define CHIP_NUM_5745X		0xd730
 
+#define CHIP_NUM_58802		0xd802
+#define CHIP_NUM_58808		0xd808
+
 #define BNXT_CHIP_NUM_5730X(chip_num)		\
 	((chip_num) >= CHIP_NUM_57301 &&	\
 	 (chip_num) <= CHIP_NUM_57304)
@@ -1021,6 +1024,10 @@ struct bnxt {
 #define BNXT_CHIP_NUM_57X1X(chip_num)		\
 	(BNXT_CHIP_NUM_5731X(chip_num) || BNXT_CHIP_NUM_5741X(chip_num))
 
+#define BNXT_CHIP_NUM_588XX(chip_num)		\
+	((chip_num) == CHIP_NUM_58802 ||	\
+	 (chip_num) == CHIP_NUM_58808)
+
 	struct net_device	*dev;
 	struct pci_dev		*pdev;
 
@@ -1079,6 +1086,7 @@ struct bnxt {
 #define BNXT_CHIP_P4_PLUS(bp)			\
 	(BNXT_CHIP_NUM_57X1X((bp)->chip_num) ||	\
 	 BNXT_CHIP_NUM_5745X((bp)->chip_num) ||	\
+	 BNXT_CHIP_NUM_588XX((bp)->chip_num) ||	\
 	 (BNXT_CHIP_NUM_58700((bp)->chip_num) &&	\
 	  !BNXT_CHIP_TYPE_NITRO_A0(bp)))
 
-- 
1.8.3.1
