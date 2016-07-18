From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 6/6] bnxt_en: Add BCM58700 PCI device ID for NS2 Nitro.
Date: Mon, 18 Jul 2016 07:15:25 -0400
Message-ID: <1468840525-340-7-git-send-email-michael.chan@broadcom.com>
References: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:32849 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbcGRLPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:15:40 -0400
Received: by mail-oi0-f50.google.com with SMTP id j185so240652786oih.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 04:15:39 -0700 (PDT)
In-Reply-To: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant.sreedharan@broadcom.com>

A bridge device in NS2 has the same device ID as the ethernet controller.
Add check to avoid probing the bridge device.

Signed-off-by: Prashant Sreedharan <prashant.sreedharan@broadcom.com>
Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index fd6a174..b55eef2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -73,6 +73,7 @@ enum board_idx {
 	BCM57301,
 	BCM57302,
 	BCM57304,
+	BCM58700,
 	BCM57311,
 	BCM57312,
 	BCM57402,
@@ -98,6 +99,7 @@ static const struct {
 	{ "Broadcom BCM57301 NetXtreme-C Single-port 10Gb Ethernet" },
 	{ "Broadcom BCM57302 NetXtreme-C Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57304 NetXtreme-C Dual-port 10Gb/25Gb/40Gb/50Gb Ethernet" },
+	{ "Broadcom BCM58700 Nitro 4-port 1Gb/2.5Gb/10Gb Ethernet" },
 	{ "Broadcom BCM57311 NetXtreme-C Single-port 10Gb Ethernet" },
 	{ "Broadcom BCM57312 NetXtreme-C Dual-port 10Gb/25Gb Ethernet" },
 	{ "Broadcom BCM57402 NetXtreme-E Dual-port 10Gb Ethernet" },
@@ -120,6 +122,7 @@ static const struct pci_device_id bnxt_pci_tbl[] = {
 	{ PCI_VDEVICE(BROADCOM, 0x16c8), .driver_data = BCM57301 },
 	{ PCI_VDEVICE(BROADCOM, 0x16c9), .driver_data = BCM57302 },
 	{ PCI_VDEVICE(BROADCOM, 0x16ca), .driver_data = BCM57304 },
+	{ PCI_VDEVICE(BROADCOM, 0x16cd), .driver_data = BCM58700 },
 	{ PCI_VDEVICE(BROADCOM, 0x16ce), .driver_data = BCM57311 },
 	{ PCI_VDEVICE(BROADCOM, 0x16cf), .driver_data = BCM57312 },
 	{ PCI_VDEVICE(BROADCOM, 0x16d0), .driver_data = BCM57402 },
@@ -6715,6 +6718,9 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct bnxt *bp;
 	int rc, max_irqs;
 
+	if (pdev->device == 0x16cd && pci_is_bridge(pdev))
+		return -ENODEV;
+
 	if (version_printed++ == 0)
 		pr_info("%s", version);
 
-- 
1.8.3.1
