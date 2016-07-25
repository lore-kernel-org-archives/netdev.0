From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/3] bnxt_en: Add new NPAR and dual media device IDs.
Date: Sun, 24 Jul 2016 23:21:57 -0400
Message-ID: <1469416917-29659-4-git-send-email-michael.chan@broadcom.com>
References: <1469416917-29659-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33588 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbcGYDWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2016 23:22:09 -0400
Received: by mail-pa0-f48.google.com with SMTP id ks6so56667813pab.0
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 20:22:09 -0700 (PDT)
In-Reply-To: <1469416917-29659-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 5741X/5731X NPAR device IDs and dual media SFP/10GBase-T device IDs.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 39 ++++++++++++++++++++++++++-----
 1 file changed, 33 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 398ecba..1d5dd5b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -73,19 +73,28 @@ enum board_idx {
 	BCM57301,
 	BCM57302,
 	BCM57304,
+	BCM57417_NPAR,
 	BCM58700,
 	BCM57311,
 	BCM57312,
 	BCM57402,
 	BCM57404,
 	BCM57406,
-	BCM57404_NPAR,
+	BCM57402_NPAR,
+	BCM57407,
 	BCM57412,
 	BCM57414,
 	BCM57416,
 	BCM57417,
-	BCM57414_NPAR,
+	BCM57412_NPAR,
 	BCM57314,
+	BCM57417_SFP,
+	BCM57416_SFP,
+	BCM57404_NPAR,
+	BCM57406_NPAR,
+	BCM57407_SFP,
+	BCM57414_NPAR,
+	BCM57416_NPAR,
 	BCM57304_VF,
 	BCM57404_VF,
 	BCM57414_VF,
@@ -99,19 +108,28 @@ static const struct {
 	{ "Broadcom BCM57301 NetXtreme-C Single-port 10Gb Ethernet" },
 	{ "Broadcom BCM57302 NetXtreme-C Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57304 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM57417 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM58700 Nitro 4-port 1Gb/2.5Gb/10Gb Ethernet" },
 	{ "Broadcom BCM57311 NetXtreme-C Single-port 10Gb Ethernet" },
 	{ "Broadcom BCM57312 NetXtreme-C Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57402 NetXtreme-E Dual-port 10Gb Ethernet" },
 	{ "Broadcom BCM57404 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57406 NetXtreme-E Dual-port 10GBase-T Ethernet" },
-	{ "Broadcom BCM57404 NetXtreme-E Ethernet Partition" },
+	{ "Broadcom BCM57402 NetXtreme-E Ethernet Partition" },
+	{ "Broadcom BCM57407 NetXtreme-E Dual-port 10GBase-T Ethernet" },
 	{ "Broadcom BCM57412 NetXtreme-E Dual-port 10Gb Ethernet" },
 	{ "Broadcom BCM57414 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57416 NetXtreme-E Dual-port 10GBase-T Ethernet" },
 	{ "Broadcom BCM57417 NetXtreme-E Dual-port 10GBase-T Ethernet" },
-	{ "Broadcom BCM57414 NetXtreme-E Ethernet Partition" },
+	{ "Broadcom BCM57412 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM57314 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM57417 NetXtreme-E Dual-port 10Gb/25Gb Ethernet" },
+	{ "Broadcom BCM57416 NetXtreme-E Dual-port 10Gb Ethernet" },
+	{ "Broadcom BCM57404 NetXtreme-E Ethernet Partition" },
+	{ "Broadcom BCM57406 NetXtreme-E Ethernet Partition" },
+	{ "Broadcom BCM57407 NetXtreme-E Dual-port 25Gb Ethernet" },
+	{ "Broadcom BCM57414 NetXtreme-E Ethernet Partition" },
+	{ "Broadcom BCM57416 NetXtreme-E Ethernet Partition" },
 	{ "Broadcom BCM57304 NetXtreme-C Ethernet Virtual Function" },
 	{ "Broadcom BCM57404 NetXtreme-E Ethernet Virtual Function" },
 	{ "Broadcom BCM57414 NetXtreme-E Ethernet Virtual Function" },
@@ -122,19 +140,28 @@ static const struct pci_device_id bnxt_pci_tbl[] = {
 	{ PCI_VDEVICE(BROADCOM, 0x16c8), .driver_data = BCM57301 },
 	{ PCI_VDEVICE(BROADCOM, 0x16c9), .driver_data = BCM57302 },
 	{ PCI_VDEVICE(BROADCOM, 0x16ca), .driver_data = BCM57304 },
+	{ PCI_VDEVICE(BROADCOM, 0x16cc), .driver_data = BCM57417_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16cd), .driver_data = BCM58700 },
 	{ PCI_VDEVICE(BROADCOM, 0x16ce), .driver_data = BCM57311 },
 	{ PCI_VDEVICE(BROADCOM, 0x16cf), .driver_data = BCM57312 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d0), .driver_data = BCM57402 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d1), .driver_data = BCM57404 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d2), .driver_data = BCM57406 },
-	{ PCI_VDEVICE(BROADCOM, 0x16d4), .driver_data = BCM57404_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16d4), .driver_data = BCM57402_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16d5), .driver_data = BCM57407 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d6), .driver_data = BCM57412 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d7), .driver_data = BCM57414 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d8), .driver_data = BCM57416 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d9), .driver_data = BCM57417 },
-	{ PCI_VDEVICE(BROADCOM, 0x16de), .driver_data = BCM57414_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16de), .driver_data = BCM57412_NPAR },
 	{ PCI_VDEVICE(BROADCOM, 0x16df), .driver_data = BCM57314 },
+	{ PCI_VDEVICE(BROADCOM, 0x16e2), .driver_data = BCM57417_SFP },
+	{ PCI_VDEVICE(BROADCOM, 0x16e3), .driver_data = BCM57416_SFP },
+	{ PCI_VDEVICE(BROADCOM, 0x16e7), .driver_data = BCM57404_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16e8), .driver_data = BCM57406_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16e9), .driver_data = BCM57407_SFP },
+	{ PCI_VDEVICE(BROADCOM, 0x16ec), .driver_data = BCM57414_NPAR },
+	{ PCI_VDEVICE(BROADCOM, 0x16ee), .driver_data = BCM57416_NPAR },
 #ifdef CONFIG_BNXT_SRIOV
 	{ PCI_VDEVICE(BROADCOM, 0x16cb), .driver_data = BCM57304_VF },
 	{ PCI_VDEVICE(BROADCOM, 0x16d3), .driver_data = BCM57404_VF },
-- 
1.8.3.1
