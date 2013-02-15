From: Christian Ruppert <christian.ruppert@abilis.com>
Subject: [PATCH v2] Prevent interrupt loop with DWMAC MMC RX IPC Counter
Date: Fri, 15 Feb 2013 15:58:02 +0100
Message-ID: <1360940282-27211-1-git-send-email-christian.ruppert@abilis.com>
References: <20130215144815.GA31098@ab42.lan>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Christian Ruppert <christian.ruppert@abilis.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130215144815.GA31098@ab42.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the DesignWare MAC is synthesised with MMC RX IPC Counter, an unmanaged
and unacknowledged interrupt is generated after some time of operation.

This patch masks the undesired interrupts.

Signed-off-by: Christian Ruppert <christian.ruppert@abilis.com>
---
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
index 0c74a70..50617c5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
@@ -149,6 +149,7 @@ void dwmac_mmc_intr_all_mask(void __iomem *ioaddr)
 {
 	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_INTR_MASK);
 	writel(MMC_DEFAULT_MASK, ioaddr + MMC_TX_INTR_MASK);
+	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_IPC_INTR_MASK);
 }
 
 /* This reads the MAC core counters (if actaully supported).
-- 
1.7.1
