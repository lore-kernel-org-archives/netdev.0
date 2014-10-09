From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net] stmmac: correct mc_filter local variable in set_filter and set_mac_addr call
Date: Thu, 9 Oct 2014 10:10:36 -0500
Message-ID: <1412867436-22153-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@altera.com>, <vbridger@opensource.altera.com>
To: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Testing revealed that the local variable mc_filter was dimensioned
incorrectly for all possible configurations and get_mac_addr should
have been set_mac_addr (a typo). Make sure mc_filter is dimensioned
to 8 32-bit unsigned longs - the largest size of the Synopsys
multicast filter register set.

Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 5efe60e..0adcf73 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -134,7 +134,7 @@ static void dwmac1000_set_filter(struct mac_device_info *hw,
 	void __iomem *ioaddr = (void __iomem *)dev->base_addr;
 	unsigned int value = 0;
 	unsigned int perfect_addr_number = hw->unicast_filter_entries;
-	u32 mc_filter[2];
+	u32 mc_filter[8];
 	int mcbitslog2 = hw->mcast_bits_log2;
 
 	pr_debug("%s: # mcasts %d, # unicast %d\n", __func__,
@@ -182,7 +182,7 @@ static void dwmac1000_set_filter(struct mac_device_info *hw,
 		struct netdev_hw_addr *ha;
 
 		netdev_for_each_uc_addr(ha, dev) {
-			stmmac_get_mac_addr(ioaddr, ha->addr,
+			stmmac_set_mac_addr(ioaddr, ha->addr,
 					    GMAC_ADDR_HIGH(reg),
 					    GMAC_ADDR_LOW(reg));
 			reg++;
-- 
1.9.1
