From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 02/10] bnxt_en: Simplify PCI device names and add additinal PCI IDs.
Date: Tue, 20 Sep 2016 02:50:20 -0400
Message-ID: <1474354228-3221-3-git-send-email-michael.chan@broadcom.com>
References: <1474354228-3221-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org,
        David Christensen <david.christensen@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34678 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752744AbcITGuj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 02:50:39 -0400
Received: by mail-pa0-f45.google.com with SMTP id wk8so3911662pab.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 23:50:39 -0700 (PDT)
In-Reply-To: <1474354228-3221-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove "Single-port/Dual-port" from the device names.  Dual-port devices
will appear as 2 separate devices, so no need to call each a dual-port
device.  Use a more generic name for VF devices belonging to the same
chip fanmily.  Add some remaining NPAR device IDs.

Signed-off-by: David Christensen <david.christensen@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 68 ++++++++++++++++---------------
 1 file changed, 36 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index cee0e8d..d9b4cd1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -93,50 +93,49 @@ enum board_idx {
 	BCM57404_NPAR,
 	BCM57406_NPAR,
 	BCM57407_SFP,
+	BCM57407_NPAR,
 	BCM57414_NPAR,
 	BCM57416_NPAR,
-	BCM57304_VF,
-	BCM57404_VF,
-	BCM57414_VF,
-	BCM57314_VF,
+	NETXTREME_E_VF,
+	NETXTREME_C_VF,
 };
 
 /* indexed by enum above */
 static const struct {
 	char *name;
 } board_info[] = {
-	{ "Broadcom BCM57301 NetXtreme-C Single-port 10Gb Ethernet" },
-	{ "Broadcom BCM57302 NetXtreme-C Dual-port 10Gb/25Gb Ethernet" },
-	{ "Broadcom BCM57304 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM57301 NetXtreme-C 10Gb Ethernet" },
+	{ "Broadcom BCM57302 NetXtreme-C 10Gb/25Gb Ethernet" },
+	{ "Broadcom BCM57304 NetXtreme-C 10Gb/25Gb/40Gb/50Gb Ethernet" },
 	{ "Broadcom BCM57417 NetXtreme-E Ethernet Partition" },
-	{ "Broadcom BCM58700 Nitro 4-port 1Gb/2.5Gb/10Gb Ethernet" },
-	{ "Broadcom BCM57311 NetXtreme-C Single-port 10Gb Ethernet" },
-	{ "Broadcom BCM57312 NetXtreme-C Dual-port 10Gb/25Gb Ethernet" },
-	{ "Broadcom BCM57402 NetXtreme-E Dual-port 10Gb Ethernet" },
-	{ "Broadcom BCM57404 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
-	{ "Broadcom BCM57406 NetXtreme-E Dual-port 10GBase-T Ethernet" },
+	{ "Broadcom BCM58700 Nitro 1Gb/2.5Gb/10Gb Ethernet" },
+	{ "Broadcom BCM57311 NetXtreme-C 10Gb Ethernet" },
+	{ "Broadcom BCM57312 NetXtreme-C 10Gb/25Gb Ethernet" },
+	{ "Broadcom BCM57402 NetXtreme-E 10Gb Ethernet" },
+	{ "Broadcom BCM57404 NetXtreme-E 10Gb/25Gb Ethernet" },
+	{ "Broadcom BCM57406 NetXtreme-E 10GBase-T Ethernet" },
 	{ "Broadcom BCM57402 NetXtreme-E Ethernet Partition" },
-	{ "Broadcom BCM57407 NetXtreme-E Dual-port 10GBase-T Ethernet" },
-	{ "Broadcom BCM57412 NetXtreme-E Dual-port 10Gb Ethernet" },
-	{ "Broadcom BCM57414 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
-	{ "Broadcom BCM57416 NetXtreme-E Dual-port 10GBase-T Ethernet" },
-	{ "Broadcom BCM57417 NetXtreme-E Dual-port 10GBase-T Ethernet" },
+	{ "Broadcom BCM57407 NetXtreme-E 10GBase-T Ethernet" },
+	{ "Broadcom BCM57412 NetXtreme-E 10Gb Ethernet" },
+	{ "Broadcom BCM57414 NetXtreme-E 10Gb/25Gb Ethernet" },
+	{ "Broadcom BCM57416 NetXtreme-E 10GBase-T Ethernet" },
+	{ "Broadcom BCM57417 NetXtreme-E 10GBase-T Ethernet" },
 	{ "Broadcom BCM57412 NetXtreme-E Ethernet Partition" },
-	{ "Broadcom BCM57314 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
-	{ "Broadcom BCM57417 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
-	{ "Broadcom BCM57416 NetXtreme-E Dual-port 10Gb Ethernet" },
+	{ "Broadcom BCM57314 NetXtreme-C 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM57417 NetXtreme-E 10Gb/25Gb Ethernet" },
+	{ "Broadcom BCM57416 NetXtreme-E 10Gb Ethernet" },
 	{ "Broadcom BCM57404 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM57406 NetXtreme-E Ethernet Partition" },
-	{ "Broadcom BCM57407 NetXtreme-E Dual-port 25Gb Ethernet" },
+	{ "Broadcom BCM57407 NetXtreme-E 25Gb Ethernet" },
+	{ "Broadcom BCM57407 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM57414 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM57416 NetXtreme-E Ethernet Partition" },
-	{ "Broadcom BCM57304 NetXtreme-C Ethernet Virtual Function" },
-	{ "Broadcom BCM57404 NetXtreme-E Ethernet Virtual Function" },
-	{ "Broadcom BCM57414 NetXtreme-E Ethernet Virtual Function" },
-	{ "Broadcom BCM57314 NetXtreme-E Ethernet Virtual Function" },
+	{ "Broadcom NetXtreme-E Ethernet Virtual Function" },
+	{ "Broadcom NetXtreme-C Ethernet Virtual Function" },
 };
 
 static const struct pci_device_id bnxt_pci_tbl[] = {
+	{ PCI_VDEVICE(BROADCOM, 0x16c0), .driver_data = BCM57417_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16c8), .driver_data = BCM57301 },
 	{ PCI_VDEVICE(BROADCOM, 0x16c9), .driver_data = BCM57302 },
 	{ PCI_VDEVICE(BROADCOM, 0x16ca), .driver_data = BCM57304 },
@@ -160,13 +159,19 @@ static const struct pci_device_id bnxt_pci_tbl[] = {
 	{ PCI_VDEVICE(BROADCOM, 0x16e7), .driver_data = BCM57404_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16e8), .driver_data = BCM57406_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16e9), .driver_data = BCM57407_SFP },
+	{ PCI_VDEVICE(BROADCOM, 0x16ea), .driver_data = BCM57407_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16eb), .driver_data = BCM57412_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16ec), .driver_data = BCM57414_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16ed), .driver_data = BCM57414_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16ee), .driver_data = BCM57416_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16ef), .driver_data = BCM57416_NPAR },
 #ifdef CONFIG_BNXT_SRIOV
-	{ PCI_VDEVICE(BROADCOM, 0x16cb), .driver_data = BCM57304_VF },
-	{ PCI_VDEVICE(BROADCOM, 0x16d3), .driver_data = BCM57404_VF },
-	{ PCI_VDEVICE(BROADCOM, 0x16dc), .driver_data = BCM57414_VF },
-	{ PCI_VDEVICE(BROADCOM, 0x16e1), .driver_data = BCM57314_VF },
+	{ PCI_VDEVICE(BROADCOM, 0x16c1), .driver_data = NETXTREME_E_VF },
+	{ PCI_VDEVICE(BROADCOM, 0x16cb), .driver_data = NETXTREME_C_VF },
+	{ PCI_VDEVICE(BROADCOM, 0x16d3), .driver_data = NETXTREME_E_VF },
+	{ PCI_VDEVICE(BROADCOM, 0x16dc), .driver_data = NETXTREME_E_VF },
+	{ PCI_VDEVICE(BROADCOM, 0x16e1), .driver_data = NETXTREME_C_VF },
+	{ PCI_VDEVICE(BROADCOM, 0x16e5), .driver_data = NETXTREME_C_VF },
 #endif
 	{ 0 }
 };
@@ -189,8 +194,7 @@ static const u16 bnxt_async_events_arr[] = {
 
 static bool bnxt_vf_pciid(enum board_idx idx)
 {
-	return (idx == BCM57304_VF || idx == BCM57404_VF ||
-		idx == BCM57314_VF || idx == BCM57414_VF);
+	return (idx == NETXTREME_C_VF || idx == NETXTREME_E_VF);
 }
 
 #define DB_CP_REARM_FLAGS	(DB_KEY_CP | DB_IDX_VALID)
-- 
1.8.3.1
