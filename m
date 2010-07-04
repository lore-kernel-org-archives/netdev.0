From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/4] bnx2: Dump some config space registers
 during TX timeout.
Date: Sat, 3 Jul 2010 23:42:17 -0700
Message-ID: <1278225738-7795-3-git-send-email-mchan@broadcom.com>
References: <1278225738-7795-1-git-send-email-mchan@broadcom.com>
 <1278225738-7795-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1338 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754633Ab0GDGjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jul 2010 02:39:40 -0400
In-Reply-To: <1278225738-7795-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These config register values will be useful when the memory registers
are returning 0xffffffff which has been reported.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ae0a9af..22fa1e9 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6313,9 +6313,14 @@ static void
 bnx2_dump_state(struct bnx2 *bp)
 {
 	struct net_device *dev = bp->dev;
-	u32 mcp_p0, mcp_p1;
-
-	netdev_err(dev, "DEBUG: intr_sem[%x]\n", atomic_read(&bp->intr_sem));
+	u32 mcp_p0, mcp_p1, val1, val2;
+
+	pci_read_config_dword(bp->pdev, PCI_COMMAND, &val1);
+	netdev_err(dev, "DEBUG: intr_sem[%x] PCI_CMD[%08x]\n",
+		   atomic_read(&bp->intr_sem), val1);
+	pci_read_config_dword(bp->pdev, bp->pm_cap + PCI_PM_CTRL, &val1);
+	pci_read_config_dword(bp->pdev, BNX2_PCICFG_MISC_CONFIG, &val2);
+	netdev_err(dev, "DEBUG: PCI_PM[%08x] PCI_MISC_CFG[%08x]\n", val1, val2);
 	netdev_err(dev, "DEBUG: EMAC_TX_STATUS[%08x] EMAC_RX_STATUS[%08x]\n",
 		   REG_RD(bp, BNX2_EMAC_TX_STATUS),
 		   REG_RD(bp, BNX2_EMAC_RX_STATUS));
-- 
1.6.4.GIT


