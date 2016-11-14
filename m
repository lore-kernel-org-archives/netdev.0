From: sunil.kovvuri@gmail.com
Subject: [PATCH 1/5] net: thunderx: Introduce BGX_ID_MASK macro to extract bgx_id
Date: Mon, 14 Nov 2016 16:24:42 +0530
Message-ID: <1479120886-13425-2-git-send-email-sunil.kovvuri@gmail.com>
References: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33523 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932388AbcKNKzk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 05:55:40 -0500
In-Reply-To: <1479120886-13425-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>

This patch fixes the 'bgx_id' determination on 83xx where there are
4 BGX blocks instead of 2 on other platforms.

Signed-off-by: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 4 ++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 8bbaedb..050e21f 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -1242,8 +1242,8 @@ static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_read_config_word(pdev, PCI_DEVICE_ID, &sdevid);
 	if (sdevid != PCI_DEVICE_ID_THUNDER_RGX) {
-		bgx->bgx_id =
-		    (pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM) >> 24) & 1;
+		bgx->bgx_id = (pci_resource_start(pdev,
+			PCI_CFG_REG_BAR_NUM) >> 24) & BGX_ID_MASK;
 		bgx->bgx_id += nic_get_node_id(pdev) * MAX_BGX_PER_NODE;
 		bgx->max_lmac = MAX_LMAC_PER_BGX;
 		bgx_vnic[bgx->bgx_id] = bgx;
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index d59c71e..01cc7c8 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -28,6 +28,8 @@
 #define    MAX_DMAC_PER_LMAC			8
 #define    MAX_FRAME_SIZE			9216
 
+#define	   BGX_ID_MASK				0x3
+
 #define    MAX_DMAC_PER_LMAC_TNS_BYPASS_MODE	2
 
 /* Registers */
-- 
2.7.4
