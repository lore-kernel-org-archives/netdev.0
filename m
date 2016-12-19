From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net 2/2] net: netcp: ethss: fix 10gbe host port tx pri map configuration
Date: Mon, 19 Dec 2016 17:55:57 -0500
Message-ID: <1482188157-24490-2-git-send-email-m-karicheri2@ti.com>
References: <1482188157-24490-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482188157-24490-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2@ti.com>

This patch adds the missing 10gbe host port tx priority map
configurations.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index a31931c..7d9e36f 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -94,6 +94,7 @@
 
 /* offset relative to base of XGBE_SS_REG_INDEX */
 #define XGBE10_SGMII_MODULE_OFFSET	0x100
+#define IS_SS_ID_XGBE(d)		((d)->ss_version == XGBE_SS_VERSION_10)
 /* offset relative to base of XGBE_SM_REG_INDEX */
 #define XGBE10_HOST_PORT_OFFSET		0x34
 #define XGBE10_SLAVE_PORT_OFFSET	0x64
@@ -2322,7 +2323,7 @@ static void gbe_init_host_port(struct gbe_priv *priv)
 	int bypass_en = 1;
 
 	/* Host Tx Pri */
-	if (IS_SS_ID_NU(priv))
+	if (IS_SS_ID_NU(priv) || IS_SS_ID_XGBE(priv))
 		writel(HOST_TX_PRI_MAP_DEFAULT,
 		       GBE_REG_ADDR(priv, host_port_regs, tx_pri_map));
 
-- 
1.9.1
