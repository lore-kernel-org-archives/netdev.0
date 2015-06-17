From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 3/3] bna: remove superfluous parentheses
Date: Wed, 17 Jun 2015 18:41:58 +0200
Message-ID: <1434559318-31070-4-git-send-email-ivecera@redhat.com>
References: <1434559318-31070-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755817AbbFQQlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 12:41:25 -0400
In-Reply-To: <1434559318-31070-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |  2 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c         | 10 +--
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c      | 98 +++++++++++-----------
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c       |  4 +-
 drivers/net/ethernet/brocade/bna/bnad.c            | 12 +--
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c    |  6 +-
 6 files changed, 66 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
index 16090fd..7e17451 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
@@ -84,7 +84,7 @@ do {								\
 		(prop) |= BFI_ADAPTER_PROTO;			\
 		(gpio) &= ~CB_GPIO_PROTO;			\
 	}							\
-	switch ((gpio)) {					\
+	switch (gpio) {						\
 	case CB_GPIO_TTV:					\
 		(prop) |= BFI_ADAPTER_TTV;			\
 	case CB_GPIO_DFLY:					\
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index b009fd7..b7a0f78 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1304,7 +1304,7 @@ bfa_nw_ioc_fwver_get(struct bfa_ioc *ioc, struct bfi_ioc_image_hdr *fwhdr)
 	for (i = 0; i < (sizeof(struct bfi_ioc_image_hdr) / sizeof(u32));
 	     i++) {
 		fwsig[i] =
-			swab32(readl((loff) + (ioc->ioc_regs.smem_page_start)));
+			swab32(readl(loff + ioc->ioc_regs.smem_page_start));
 		loff += sizeof(u32);
 	}
 }
@@ -1675,7 +1675,7 @@ bfa_raw_sem_get(void __iomem *bar)
 {
 	int	locked;
 
-	locked = readl((bar + FLASH_SEM_LOCK_REG));
+	locked = readl(bar + FLASH_SEM_LOCK_REG);
 
 	return !locked;
 }
@@ -2049,8 +2049,8 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 		/**
 		 * write smem
 		 */
-		writel((swab32(fwimg[BFA_IOC_FLASH_OFFSET_IN_CHUNK(i)])),
-			      ((ioc->ioc_regs.smem_page_start) + (loff)));
+		writel(swab32(fwimg[BFA_IOC_FLASH_OFFSET_IN_CHUNK(i)]),
+		       ioc->ioc_regs.smem_page_start + loff);
 
 		loff += sizeof(u32);
 
@@ -2213,7 +2213,7 @@ bfa_nw_ioc_smem_read(struct bfa_ioc *ioc, void *tbuf, u32 soff, u32 sz)
 
 	len = sz/sizeof(u32);
 	for (i = 0; i < len; i++) {
-		r32 = swab32(readl((loff) + (ioc->ioc_regs.smem_page_start)));
+		r32 = swab32(readl(loff + ioc->ioc_regs.smem_page_start));
 		buf[i] = be32_to_cpu(r32);
 		loff += sizeof(u32);
 
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
index 8d5c239..74e5ed5 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
@@ -535,7 +535,7 @@ bfa_ioc_ct_sync_ack(struct bfa_ioc *ioc)
 {
 	u32 r32 = readl(ioc->ioc_regs.ioc_fail_sync);
 
-	writel((r32 | bfa_ioc_ct_sync_pos(ioc)), ioc->ioc_regs.ioc_fail_sync);
+	writel(r32 | bfa_ioc_ct_sync_pos(ioc), ioc->ioc_regs.ioc_fail_sync);
 }
 
 static bool
@@ -666,7 +666,7 @@ bfa_ioc_ct_pll_init(void __iomem *rb, enum bfi_asic_mode asic_mode)
 		writel(__PMM_1T_RESET_P, (rb + PMM_1T_RESET_REG_P0));
 		writel(__PMM_1T_RESET_P, (rb + PMM_1T_RESET_REG_P1));
 	}
-	r32 = readl((rb + PSS_CTL_REG));
+	r32 = readl(rb + PSS_CTL_REG);
 	r32 &= ~__PSS_LMEM_RESET;
 	writel(r32, (rb + PSS_CTL_REG));
 	udelay(1000);
@@ -677,7 +677,7 @@ bfa_ioc_ct_pll_init(void __iomem *rb, enum bfi_asic_mode asic_mode)
 
 	writel(__EDRAM_BISTR_START, (rb + MBIST_CTL_REG));
 	udelay(1000);
-	r32 = readl((rb + MBIST_STAT_REG));
+	r32 = readl(rb + MBIST_STAT_REG);
 	writel(0, (rb + MBIST_CTL_REG));
 	return BFA_STATUS_OK;
 }
@@ -690,7 +690,7 @@ bfa_ioc_ct2_sclk_init(void __iomem *rb)
 	/*
 	 * put s_clk PLL and PLL FSM in reset
 	 */
-	r32 = readl((rb + CT2_APP_PLL_SCLK_CTL_REG));
+	r32 = readl(rb + CT2_APP_PLL_SCLK_CTL_REG);
 	r32 &= ~(__APP_PLL_SCLK_ENABLE | __APP_PLL_SCLK_LRESETN);
 	r32 |= (__APP_PLL_SCLK_ENARST | __APP_PLL_SCLK_BYPASS |
 		__APP_PLL_SCLK_LOGIC_SOFT_RESET);
@@ -700,28 +700,28 @@ bfa_ioc_ct2_sclk_init(void __iomem *rb)
 	 * Ignore mode and program for the max clock (which is FC16)
 	 * Firmware/NFC will do the PLL init appropriately
 	 */
-	r32 = readl((rb + CT2_APP_PLL_SCLK_CTL_REG));
+	r32 = readl(rb + CT2_APP_PLL_SCLK_CTL_REG);
 	r32 &= ~(__APP_PLL_SCLK_REFCLK_SEL | __APP_PLL_SCLK_CLK_DIV2);
 	writel(r32, (rb + CT2_APP_PLL_SCLK_CTL_REG));
 
 	/*
 	 * while doing PLL init dont clock gate ethernet subsystem
 	 */
-	r32 = readl((rb + CT2_CHIP_MISC_PRG));
-	writel((r32 | __ETH_CLK_ENABLE_PORT0),
-				(rb + CT2_CHIP_MISC_PRG));
+	r32 = readl(rb + CT2_CHIP_MISC_PRG);
+	writel(r32 | __ETH_CLK_ENABLE_PORT0,
+	       rb + CT2_CHIP_MISC_PRG);
 
-	r32 = readl((rb + CT2_PCIE_MISC_REG));
-	writel((r32 | __ETH_CLK_ENABLE_PORT1),
-				(rb + CT2_PCIE_MISC_REG));
+	r32 = readl(rb + CT2_PCIE_MISC_REG);
+	writel(r32 | __ETH_CLK_ENABLE_PORT1,
+	       rb + CT2_PCIE_MISC_REG);
 
 	/*
 	 * set sclk value
 	 */
-	r32 = readl((rb + CT2_APP_PLL_SCLK_CTL_REG));
+	r32 = readl(rb + CT2_APP_PLL_SCLK_CTL_REG);
 	r32 &= (__P_SCLK_PLL_LOCK | __APP_PLL_SCLK_REFCLK_SEL |
 		__APP_PLL_SCLK_CLK_DIV2);
-	writel(r32 | 0x1061731b, (rb + CT2_APP_PLL_SCLK_CTL_REG));
+	writel(r32 | 0x1061731b, rb + CT2_APP_PLL_SCLK_CTL_REG);
 
 	/*
 	 * poll for s_clk lock or delay 1ms
@@ -742,28 +742,28 @@ bfa_ioc_ct2_lclk_init(void __iomem *rb)
 	/*
 	 * put l_clk PLL and PLL FSM in reset
 	 */
-	r32 = readl((rb + CT2_APP_PLL_LCLK_CTL_REG));
+	r32 = readl(rb + CT2_APP_PLL_LCLK_CTL_REG);
 	r32 &= ~(__APP_PLL_LCLK_ENABLE | __APP_PLL_LCLK_LRESETN);
 	r32 |= (__APP_PLL_LCLK_ENARST | __APP_PLL_LCLK_BYPASS |
 		__APP_PLL_LCLK_LOGIC_SOFT_RESET);
-	writel(r32, (rb + CT2_APP_PLL_LCLK_CTL_REG));
+	writel(r32, rb + CT2_APP_PLL_LCLK_CTL_REG);
 
 	/*
 	 * set LPU speed (set for FC16 which will work for other modes)
 	 */
-	r32 = readl((rb + CT2_CHIP_MISC_PRG));
+	r32 = readl(rb + CT2_CHIP_MISC_PRG);
 	writel(r32, (rb + CT2_CHIP_MISC_PRG));
 
 	/*
 	 * set LPU half speed (set for FC16 which will work for other modes)
 	 */
-	r32 = readl((rb + CT2_APP_PLL_LCLK_CTL_REG));
-	writel(r32, (rb + CT2_APP_PLL_LCLK_CTL_REG));
+	r32 = readl(rb + CT2_APP_PLL_LCLK_CTL_REG);
+	writel(r32, rb + CT2_APP_PLL_LCLK_CTL_REG);
 
 	/*
 	 * set lclk for mode (set for FC16)
 	 */
-	r32 = readl((rb + CT2_APP_PLL_LCLK_CTL_REG));
+	r32 = readl(rb + CT2_APP_PLL_LCLK_CTL_REG);
 	r32 &= (__P_LCLK_PLL_LOCK | __APP_LPUCLK_HALFSPEED);
 	r32 |= 0x20c1731b;
 	writel(r32, (rb + CT2_APP_PLL_LCLK_CTL_REG));
@@ -779,14 +779,14 @@ bfa_ioc_ct2_mem_init(void __iomem *rb)
 {
 	u32 r32;
 
-	r32 = readl((rb + PSS_CTL_REG));
+	r32 = readl(rb + PSS_CTL_REG);
 	r32 &= ~__PSS_LMEM_RESET;
-	writel(r32, (rb + PSS_CTL_REG));
+	writel(r32, rb + PSS_CTL_REG);
 	udelay(1000);
 
-	writel(__EDRAM_BISTR_START, (rb + CT2_MBIST_CTL_REG));
+	writel(__EDRAM_BISTR_START, rb + CT2_MBIST_CTL_REG);
 	udelay(1000);
-	writel(0, (rb + CT2_MBIST_CTL_REG));
+	writel(0, rb + CT2_MBIST_CTL_REG);
 }
 
 static void
@@ -800,22 +800,22 @@ bfa_ioc_ct2_mac_reset(void __iomem *rb)
 	/*
 	 * release soft reset on s_clk & l_clk
 	 */
-	r32 = readl((rb + CT2_APP_PLL_SCLK_CTL_REG));
-	writel((r32 & ~__APP_PLL_SCLK_LOGIC_SOFT_RESET),
-			(rb + CT2_APP_PLL_SCLK_CTL_REG));
+	r32 = readl(rb + CT2_APP_PLL_SCLK_CTL_REG);
+	writel(r32 & ~__APP_PLL_SCLK_LOGIC_SOFT_RESET,
+	       rb + CT2_APP_PLL_SCLK_CTL_REG);
 
 	/*
 	 * release soft reset on s_clk & l_clk
 	 */
-	r32 = readl((rb + CT2_APP_PLL_LCLK_CTL_REG));
-	writel((r32 & ~__APP_PLL_LCLK_LOGIC_SOFT_RESET),
-			(rb + CT2_APP_PLL_LCLK_CTL_REG));
+	r32 = readl(rb + CT2_APP_PLL_LCLK_CTL_REG);
+	writel(r32 & ~__APP_PLL_LCLK_LOGIC_SOFT_RESET,
+	       rb + CT2_APP_PLL_LCLK_CTL_REG);
 
 	/* put port0, port1 MAC & AHB in reset */
-	writel((__CSI_MAC_RESET | __CSI_MAC_AHB_RESET),
-			(rb + CT2_CSI_MAC_CONTROL_REG(0)));
-	writel((__CSI_MAC_RESET | __CSI_MAC_AHB_RESET),
-			(rb + CT2_CSI_MAC_CONTROL_REG(1)));
+	writel(__CSI_MAC_RESET | __CSI_MAC_AHB_RESET,
+	       rb + CT2_CSI_MAC_CONTROL_REG(0));
+	writel(__CSI_MAC_RESET | __CSI_MAC_AHB_RESET,
+	       rb + CT2_CSI_MAC_CONTROL_REG(1));
 }
 
 #define CT2_NFC_MAX_DELAY       1000
@@ -860,8 +860,8 @@ bfa_ioc_ct2_pll_init(void __iomem *rb, enum bfi_asic_mode asic_mode)
 
 	nfc_ver = readl(rb + CT2_RSC_GPR15_REG);
 
-	if ((wgn == (__A2T_AHB_LOAD | __WGN_READY)) &&
-		(nfc_ver >= CT2_NFC_VER_VALID)) {
+	if (wgn == (__A2T_AHB_LOAD | __WGN_READY) &&
+	    nfc_ver >= CT2_NFC_VER_VALID) {
 		if (bfa_ioc_ct2_nfc_halted(rb))
 			bfa_ioc_ct2_nfc_resume(rb);
 		writel(__RESET_AND_START_SCLK_LCLK_PLLS,
@@ -898,19 +898,19 @@ bfa_ioc_ct2_pll_init(void __iomem *rb, enum bfi_asic_mode asic_mode)
 		bfa_ioc_ct2_lclk_init(rb);
 
 		/* release soft reset on s_clk & l_clk */
-		r32 = readl((rb + CT2_APP_PLL_SCLK_CTL_REG));
+		r32 = readl(rb + CT2_APP_PLL_SCLK_CTL_REG);
 		writel(r32 & ~__APP_PLL_SCLK_LOGIC_SOFT_RESET,
 				rb + CT2_APP_PLL_SCLK_CTL_REG);
-		r32 = readl((rb + CT2_APP_PLL_LCLK_CTL_REG));
+		r32 = readl(rb + CT2_APP_PLL_LCLK_CTL_REG);
 		writel(r32 & ~__APP_PLL_LCLK_LOGIC_SOFT_RESET,
 				rb + CT2_APP_PLL_LCLK_CTL_REG);
 	}
 
 	/* Announce flash device presence, if flash was corrupted. */
 	if (wgn == (__WGN_READY | __GLBL_PF_VF_CFG_RDY)) {
-		r32 = readl((rb + PSS_GPIO_OUT_REG));
+		r32 = readl(rb + PSS_GPIO_OUT_REG);
 		writel(r32 & ~1, rb + PSS_GPIO_OUT_REG);
-		r32 = readl((rb + PSS_GPIO_OE_REG));
+		r32 = readl(rb + PSS_GPIO_OE_REG);
 		writel(r32 | 1, rb + PSS_GPIO_OE_REG);
 	}
 
@@ -918,27 +918,27 @@ bfa_ioc_ct2_pll_init(void __iomem *rb, enum bfi_asic_mode asic_mode)
 	 * Mask the interrupts and clear any
 	 * pending interrupts left by BIOS/EFI
 	 */
-	writel(1, (rb + CT2_LPU0_HOSTFN_MBOX0_MSK));
-	writel(1, (rb + CT2_LPU1_HOSTFN_MBOX0_MSK));
+	writel(1, rb + CT2_LPU0_HOSTFN_MBOX0_MSK);
+	writel(1, rb + CT2_LPU1_HOSTFN_MBOX0_MSK);
 
 	/* For first time initialization, no need to clear interrupts */
 	r32 = readl(rb + HOST_SEM5_REG);
 	if (r32 & 0x1) {
-		r32 = readl((rb + CT2_LPU0_HOSTFN_CMD_STAT));
+		r32 = readl(rb + CT2_LPU0_HOSTFN_CMD_STAT);
 		if (r32 == 1) {
-			writel(1, (rb + CT2_LPU0_HOSTFN_CMD_STAT));
-			readl((rb + CT2_LPU0_HOSTFN_CMD_STAT));
+			writel(1, rb + CT2_LPU0_HOSTFN_CMD_STAT);
+			readl(rb + CT2_LPU0_HOSTFN_CMD_STAT);
 		}
-		r32 = readl((rb + CT2_LPU1_HOSTFN_CMD_STAT));
+		r32 = readl(rb + CT2_LPU1_HOSTFN_CMD_STAT);
 		if (r32 == 1) {
-			writel(1, (rb + CT2_LPU1_HOSTFN_CMD_STAT));
-			readl((rb + CT2_LPU1_HOSTFN_CMD_STAT));
+			writel(1, rb + CT2_LPU1_HOSTFN_CMD_STAT);
+			readl(rb + CT2_LPU1_HOSTFN_CMD_STAT);
 		}
 	}
 
 	bfa_ioc_ct2_mem_init(rb);
 
-	writel(BFI_IOC_UNINIT, (rb + CT2_BFA_IOC0_STATE_REG));
-	writel(BFI_IOC_UNINIT, (rb + CT2_BFA_IOC1_STATE_REG));
+	writel(BFI_IOC_UNINIT, rb + CT2_BFA_IOC0_STATE_REG);
+	writel(BFI_IOC_UNINIT, rb + CT2_BFA_IOC1_STATE_REG);
 	return BFA_STATUS_OK;
 }
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 33f5e55..5d0753c 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -933,7 +933,7 @@ bna_rx_vlan_add(struct bna_rx *rx, int vlan_id)
 {
 	struct bna_rxf *rxf = &rx->rxf;
 	int index = (vlan_id >> BFI_VLAN_WORD_SHIFT);
-	int bit = BIT((vlan_id & BFI_VLAN_WORD_MASK));
+	int bit = BIT(vlan_id & BFI_VLAN_WORD_MASK);
 	int group_id = (vlan_id >> BFI_VLAN_BLOCK_SHIFT);
 
 	rxf->vlan_filter_table[index] |= bit;
@@ -948,7 +948,7 @@ bna_rx_vlan_del(struct bna_rx *rx, int vlan_id)
 {
 	struct bna_rxf *rxf = &rx->rxf;
 	int index = (vlan_id >> BFI_VLAN_WORD_SHIFT);
-	int bit = BIT((vlan_id & BFI_VLAN_WORD_MASK));
+	int bit = BIT(vlan_id & BFI_VLAN_WORD_MASK);
 	int group_id = (vlan_id >> BFI_VLAN_BLOCK_SHIFT);
 
 	rxf->vlan_filter_table[index] &= ~bit;
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 85c1470..0612b19 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -309,7 +309,7 @@ bnad_rxq_alloc_init(struct bnad *bnad, struct bna_rcb *rcb)
 		}
 	}
 
-	BUG_ON(((PAGE_SIZE << order) % unmap_q->map_size));
+	BUG_ON((PAGE_SIZE << order) % unmap_q->map_size);
 
 	return 0;
 }
@@ -757,7 +757,7 @@ bnad_msix_rx(int irq, void *data)
 	struct bna_ccb *ccb = (struct bna_ccb *)data;
 
 	if (ccb) {
-		((struct bnad_rx_ctrl *)(ccb->ctrl))->rx_intr_ctr++;
+		((struct bnad_rx_ctrl *)ccb->ctrl)->rx_intr_ctr++;
 		bnad_netif_rx_schedule_poll(ccb->bnad, ccb);
 	}
 
@@ -3677,13 +3677,13 @@ bnad_pci_probe(struct pci_dev *pdev,
 
 	/* Set up timers */
 	setup_timer(&bnad->bna.ioceth.ioc.ioc_timer, bnad_ioc_timeout,
-				((unsigned long)bnad));
+		    (unsigned long)bnad);
 	setup_timer(&bnad->bna.ioceth.ioc.hb_timer, bnad_ioc_hb_check,
-				((unsigned long)bnad));
+		    (unsigned long)bnad);
 	setup_timer(&bnad->bna.ioceth.ioc.iocpf_timer, bnad_iocpf_timeout,
-				((unsigned long)bnad));
+		    (unsigned long)bnad);
 	setup_timer(&bnad->bna.ioceth.ioc.sem_timer, bnad_iocpf_sem_timeout,
-				((unsigned long)bnad));
+		    (unsigned long)bnad);
 
 	/*
 	 * Start the chip
diff --git a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
index c0fd737..8fc246e 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
@@ -268,15 +268,15 @@ bna_reg_offset_check(struct bfa_ioc *ioc, u32 offset, u32 len)
 	area = (offset >> 15) & 0x7;
 	if (area == 0) {
 		/* PCIe core register */
-		if ((offset + (len<<2)) > 0x8000)	/* 8k dwords or 32KB */
+		if (offset + (len << 2) > 0x8000)	/* 8k dwords or 32KB */
 			return BFA_STATUS_EINVAL;
 	} else if (area == 0x1) {
 		/* CB 32 KB memory page */
-		if ((offset + (len<<2)) > 0x10000)	/* 8k dwords or 32KB */
+		if (offset + (len << 2) > 0x10000)	/* 8k dwords or 32KB */
 			return BFA_STATUS_EINVAL;
 	} else {
 		/* CB register space 64KB */
-		if ((offset + (len<<2)) > BFA_REG_ADDRMSK(ioc))
+		if (offset + (len << 2) > BFA_REG_ADDRMSK(ioc))
 			return BFA_STATUS_EINVAL;
 	}
 	return BFA_STATUS_OK;
-- 
2.3.6
