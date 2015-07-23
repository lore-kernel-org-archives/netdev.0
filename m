From: WingMan Kwok <w-kwok2@ti.com>
Subject: [net-next PATCH v1 2/6] net: netcp: Fixes hw statistics module base setting error
Date: Thu, 23 Jul 2015 15:57:20 -0400
Message-ID: <1437681444-23109-3-git-send-email-w-kwok2@ti.com>
References: <1437681444-23109-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437681444-23109-1-git-send-email-w-kwok2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes error in the setting of the hw statistics
module base for K2HK platform.  In K2HK although there are
4 hw statistics modules, but only 2 are visible at a time.
Thus when setting up the pointers to the base of the
corresponding hw statistics modules, modules 0 and 2 should
point to one base, while modules 1 and 3 should point to the
other.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index cabf977..b954856 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2675,10 +2675,14 @@ static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->sgmii_port_regs = gbe_dev->ss_regs + GBE13_SGMII_MODULE_OFFSET;
 	gbe_dev->host_port_regs = gbe_dev->switch_regs + GBE13_HOST_PORT_OFFSET;
 
+	/* K2HK has only 2 hw stats modules visible at a time, so
+	 * module 0 & 2 points to one base and
+	 * module 1 & 3 points to the other base
+	 */
 	for (i = 0; i < gbe_dev->max_num_slaves; i++) {
 		gbe_dev->hw_stats_regs[i] =
 			gbe_dev->switch_regs + GBE13_HW_STATS_OFFSET +
-			(GBE_HW_STATS_REG_MAP_SZ * i);
+			(GBE_HW_STATS_REG_MAP_SZ * (i & 0x1));
 	}
 
 	gbe_dev->ale_reg = gbe_dev->switch_regs + GBE13_ALE_OFFSET;
-- 
1.7.9.5
