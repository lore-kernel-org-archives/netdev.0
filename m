From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/2] bnx2: Remove config access to non-standard
 registers
Date: Wed, 24 Nov 2010 15:48:55 -0800
Message-ID: <1290642535-20293-2-git-send-email-mchan@broadcom.com>
References: <1290642535-20293-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4885 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574Ab0KYAo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 19:44:58 -0500
In-Reply-To: <1290642535-20293-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In KVM passthrough mode, the driver may not have config access to
non-standard registers.  The BNX2_PCICFG_MISC_CONFIG config register
access to setup mailbox swapping can be done using MMIO.

Update version to 2.0.20.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 83af01d..4c0106f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.0.18"
-#define DRV_MODULE_RELDATE	"Oct 7, 2010"
+#define DRV_MODULE_VERSION	"2.0.20"
+#define DRV_MODULE_RELDATE	"Nov 24, 2010"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.0.15.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.0.17.fw"
@@ -4688,7 +4688,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 		val = BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
 		      BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP;
 
-		pci_write_config_dword(bp->pdev, BNX2_PCICFG_MISC_CONFIG, val);
+		REG_WR(bp, BNX2_PCICFG_MISC_CONFIG, val);
 
 	} else {
 		val = BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
@@ -7929,15 +7929,15 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_release;
 	}
 
+	bnx2_set_power_state(bp, PCI_D0);
+
 	/* Configure byte swap and enable write to the reg_window registers.
 	 * Rely on CPU to do target byte swapping on big endian systems
 	 * The chip's target access swapping will not swap all accesses
 	 */
-	pci_write_config_dword(bp->pdev, BNX2_PCICFG_MISC_CONFIG,
-			       BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
-			       BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP);
-
-	bnx2_set_power_state(bp, PCI_D0);
+	REG_WR(bp, BNX2_PCICFG_MISC_CONFIG,
+		   BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
+		   BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP);
 
 	bp->chip_id = REG_RD(bp, BNX2_MISC_ID);
 
-- 
1.6.4.GIT


