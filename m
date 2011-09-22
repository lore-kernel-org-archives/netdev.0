From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 2/3] bnx2x: fix WOL by enablement PME in config
 space
Date: Thu, 22 Sep 2011 15:33:32 +0300
Message-ID: <1316694813-25274-2-git-send-email-dmitry@broadcom.com>
References: <1316694813-25274-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2896 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059Ab1IVMda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 08:33:30 -0400
In-Reply-To: <1316694813-25274-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 6b46917..15f8000 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -7627,8 +7627,11 @@ u32 bnx2x_send_unload_req(struct bnx2x *bp, int unload_mode)
 		u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 		u8 *mac_addr = bp->dev->dev_addr;
 		u32 val;
+		u16 pmc;
+
 		/* The mac address is written to entries 1-4 to
-		   preserve entry 0 which is used by the PMF */
+		 * preserve entry 0 which is used by the PMF
+		 */
 		u8 entry = (BP_VN(bp) + 1)*8;
 
 		val = (mac_addr[0] << 8) | mac_addr[1];
@@ -7638,6 +7641,11 @@ u32 bnx2x_send_unload_req(struct bnx2x *bp, int unload_mode)
 		      (mac_addr[4] << 8) | mac_addr[5];
 		EMAC_WR(bp, EMAC_REG_EMAC_MAC_MATCH + entry + 4, val);
 
+		/* Enable the PME and clear the status */
+		pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL, &pmc);
+		pmc |= PCI_PM_CTRL_PME_ENABLE | PCI_PM_CTRL_PME_STATUS;
+		pci_write_config_word(bp->pdev, bp->pm_cap + PCI_PM_CTRL, pmc);
+
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
 
 	} else
-- 
1.7.2.2
