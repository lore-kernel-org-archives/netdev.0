From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 1/3] net: stmmac: change GMAC control register for SGMII
Date: Fri, 23 Nov 2012 18:04:11 +0900
Message-ID: <004b01cdc959$80af8030$820e8090$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kgene.kim@samsung.com,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net, peppe.cavallaro@st.com,
	jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch changes GMAC control register (TC(Transmit
Configuration) and PS(Port Selection) bit for SGMII.
In case of SGMII, TC bit is '1' and PS bit is 0.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c6cdbc4..a719c87 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1037,6 +1037,7 @@ static int stmmac_open(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
+	u32 value;
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
@@ -1088,6 +1089,15 @@ static int stmmac_open(struct net_device *dev)
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->ioaddr);
 
+	if (priv->phydev->interface == PHY_INTERFACE_MODE_SGMII) {
+		value = readl(priv->ioaddr);
+		/* GMAC_CONTROL_TC : transmit config in RGMII/SGMII */
+		value |= 0x1000000;
+		/* GMAC_CONTROL_PS : Port Selection for GMII */
+		value &= ~(0x8000);
+		writel(value, priv->ioaddr);
+	}
+
 	/* Request the IRQ lines */
 	ret = request_irq(dev->irq, stmmac_interrupt,
 			 IRQF_SHARED, dev->name, dev);
-- 
1.7.9.5
