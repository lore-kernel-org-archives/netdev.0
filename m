From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 2/3] net: stmmac: add SGMII RAL control bit
Date: Fri, 23 Nov 2012 18:04:12 +0900
Message-ID: <004c01cdc959$81bc5c50$853514f0$%an@samsung.com>
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


This patch sets SGMRAL bit in AN control register.
This bit forces the SGMII RAL block to operate in the
speed configured in the Speed and Port Select bits of
the GMAC Configuration register.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |    7 +++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   11 +++++++++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig
b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 9f44827..d65d63b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -54,6 +54,13 @@ config STMMAC_DA
 	  By default, the DMA arbitration scheme is based on Round-robin
 	  (rx:tx priority is 1:1).
 
+config STMMAC_SGMRAL
+	bool "STMMAC SGMII RAL Control"
+	default n
+	---help---
+	  SGMII RAL block to operate in the speed configured in the speed
+	  and port select bits of the MAC Configuration register.
+
 config STMMAC_TIMER
 	bool "STMMAC Timer optimisation"
 	default n
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a719c87..670e585 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1096,6 +1096,17 @@ static int stmmac_open(struct net_device *dev)
 		/* GMAC_CONTROL_PS : Port Selection for GMII */
 		value &= ~(0x8000);
 		writel(value, priv->ioaddr);
+
+#ifdef CONFIG_STMMAC_SGMRAL
+		value = readl(priv->ioaddr + 0xc0);
+		/*
+		 * forces RAL block to operate in speed configured
+		 * in the speed and port select bits of GMAC
+		 * configuration register
+		 */
+		value = |= 0x40000;
+		writel(value, priv->ioaddr + 0xc0);
+#endif
 	}
 
 	/* Request the IRQ lines */
-- 
1.7.9.5
