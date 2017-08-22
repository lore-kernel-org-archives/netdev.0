From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: [PATCH v2] net: stmmac: socfgpa: Ensure emac bit set in sys manager for MII/GMII/SGMII.
Date: Tue, 22 Aug 2017 14:25:07 +0200
Message-ID: <1503404707-25662-1-git-send-email-stephan.gatzka@gmail.com>
Cc: Stephan Gatzka <stephan.gatzka@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using MII/GMII/SGMII in the Altera SoC, the phy needs to be
wired through the FPGA. To ensure correct behavior, the appropriate
bit in the System Manager FPGA Interface Group register needs to be
set.

Signed-off-by: Stephan Gatzka <stephan.gatzka@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 17d4bba..6e35957 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -269,7 +269,10 @@ static int socfpga_dwmac_set_phy_mode(struct socfpga_dwmac *dwmac)
 	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << reg_shift);
 	ctrl |= val << reg_shift;
 
-	if (dwmac->f2h_ptp_ref_clk) {
+	if (dwmac->f2h_ptp_ref_clk ||
+	    phymode == PHY_INTERFACE_MODE_MII ||
+	    phymode == PHY_INTERFACE_MODE_GMII ||
+	    phymode == PHY_INTERFACE_MODE_SGMII) {
 		ctrl |= SYSMGR_EMACGRP_CTRL_PTP_REF_CLK_MASK << (reg_shift / 2);
 		regmap_read(sys_mgr_base_addr, SYSMGR_FPGAGRP_MODULE_REG,
 			    &module);
-- 
2.7.4
