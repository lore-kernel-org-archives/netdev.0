From: George Cherian <george.cherian@cavium.com>
Subject: [PATCH] net: thunderx: Fix set_max_bgx_per_node for 81xx rgx
Date: Thu, 13 Apr 2017 07:25:01 +0000
Message-ID: <1492068301-1141-1-git-send-email-george.cherian@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rric@kernel.org, sgoutham@cavium.com,
        George Cherian <george.cherian@cavium.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the PCI_SUBSYS_DEVID_81XX_RGX and use the same to set
the max bgx per node count.

This fixes the issue intoduced by following commit
78aacb6f6 net: thunderx: Fix invalid mac addresses for node1 interfaces
With this commit the max_bgx_per_node for 81xx is set as 2 instead of 3
because of which num_vfs is always calculated as zero.

Signed-off-by: George Cherian <george.cherian@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 1 +
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 64a1095..a0ca68c 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -134,6 +134,7 @@ static void set_max_bgx_per_node(struct pci_dev *pdev)
 	pci_read_config_word(pdev, PCI_SUBSYSTEM_ID, &sdevid);
 	switch (sdevid) {
 	case PCI_SUBSYS_DEVID_81XX_BGX:
+	case PCI_SUBSYS_DEVID_81XX_RGX:
 		max_bgx_per_node = MAX_BGX_PER_CN81XX;
 		break;
 	case PCI_SUBSYS_DEVID_83XX_BGX:
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index c5080f2c..6b7fe6fd 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -16,6 +16,7 @@
 /* Subsystem device IDs */
 #define PCI_SUBSYS_DEVID_88XX_BGX		0xA126
 #define PCI_SUBSYS_DEVID_81XX_BGX		0xA226
+#define PCI_SUBSYS_DEVID_81XX_RGX		0xA254
 #define PCI_SUBSYS_DEVID_83XX_BGX		0xA326
 
 #define    MAX_BGX_THUNDER			8 /* Max 2 nodes, 4 per node */
-- 
2.1.4
