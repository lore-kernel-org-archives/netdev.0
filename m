From: Christian Ruppert <christian.ruppert@abilis.com>
Subject: [PATCH] stmmac: prevent interrupt loop with MMC RX IPC Counter
Date: Wed, 10 Apr 2013 09:56:04 +0200
Message-ID: <1365580564-9149-1-git-send-email-christian.ruppert@abilis.com>
References: <511E51A9.9020908@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Christian Ruppert <christian.ruppert@abilis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.abilis.ch ([195.70.19.74]:25073 "EHLO mail.abilis.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936600Ab3DJIH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Apr 2013 04:07:29 -0400
In-Reply-To: <511E51A9.9020908@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the DesignWare MAC is synthesised with MMC RX IPC Counter, an unmanaged
and unacknowledged interrupt is generated after some time of operation.

This patch masks the undesired interrupts.

Signed-off-by: Christian Ruppert <christian.ruppert@abilis.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
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
