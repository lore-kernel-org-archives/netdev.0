From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 2/10] bnx2x: remove unnecessary dmae code
Date: Wed, 4 Apr 2012 07:41:24 +0300
Message-ID: <1333514492-20425-3-git-send-email-yuvalmin@broadcom.com>
References: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4903 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594Ab2DDErU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 00:47:20 -0400
In-Reply-To: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed uninformative debug prints, as well as two functions
which were hardly used in the code.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   91 +---------------------
 1 files changed, 4 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c03e4ab..44b6f9f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -303,67 +303,6 @@ static u32 bnx2x_reg_rd_ind(struct bnx2x *bp, u32 addr)
 #define DMAE_DP_DST_PCI		"pci dst_addr [%x:%08x]"
 #define DMAE_DP_DST_NONE	"dst_addr [none]"
 
-static void bnx2x_dp_dmae(struct bnx2x *bp, struct dmae_command *dmae,
-			  int msglvl)
-{
-	u32 src_type = dmae->opcode & DMAE_COMMAND_SRC;
-
-	switch (dmae->opcode & DMAE_COMMAND_DST) {
-	case DMAE_CMD_DST_PCI:
-		if (src_type == DMAE_CMD_SRC_PCI)
-			DP(msglvl, "DMAE: opcode 0x%08x\n"
-			   "src [%x:%08x], len [%d*4], dst [%x:%08x]\n"
-			   "comp_addr [%x:%08x], comp_val 0x%08x\n",
-			   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
-			   dmae->len, dmae->dst_addr_hi, dmae->dst_addr_lo,
-			   dmae->comp_addr_hi, dmae->comp_addr_lo,
-			   dmae->comp_val);
-		else
-			DP(msglvl, "DMAE: opcode 0x%08x\n"
-			   "src [%08x], len [%d*4], dst [%x:%08x]\n"
-			   "comp_addr [%x:%08x], comp_val 0x%08x\n",
-			   dmae->opcode, dmae->src_addr_lo >> 2,
-			   dmae->len, dmae->dst_addr_hi, dmae->dst_addr_lo,
-			   dmae->comp_addr_hi, dmae->comp_addr_lo,
-			   dmae->comp_val);
-		break;
-	case DMAE_CMD_DST_GRC:
-		if (src_type == DMAE_CMD_SRC_PCI)
-			DP(msglvl, "DMAE: opcode 0x%08x\n"
-			   "src [%x:%08x], len [%d*4], dst_addr [%08x]\n"
-			   "comp_addr [%x:%08x], comp_val 0x%08x\n",
-			   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
-			   dmae->len, dmae->dst_addr_lo >> 2,
-			   dmae->comp_addr_hi, dmae->comp_addr_lo,
-			   dmae->comp_val);
-		else
-			DP(msglvl, "DMAE: opcode 0x%08x\n"
-			   "src [%08x], len [%d*4], dst [%08x]\n"
-			   "comp_addr [%x:%08x], comp_val 0x%08x\n",
-			   dmae->opcode, dmae->src_addr_lo >> 2,
-			   dmae->len, dmae->dst_addr_lo >> 2,
-			   dmae->comp_addr_hi, dmae->comp_addr_lo,
-			   dmae->comp_val);
-		break;
-	default:
-		if (src_type == DMAE_CMD_SRC_PCI)
-			DP(msglvl, "DMAE: opcode 0x%08x\n"
-			   "src_addr [%x:%08x]  len [%d * 4]  dst_addr [none]\n"
-			   "comp_addr [%x:%08x]  comp_val 0x%08x\n",
-			   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
-			   dmae->len, dmae->comp_addr_hi, dmae->comp_addr_lo,
-			   dmae->comp_val);
-		else
-			DP(msglvl, "DMAE: opcode 0x%08x\n"
-			   "src_addr [%08x]  len [%d * 4]  dst_addr [none]\n"
-			   "comp_addr [%x:%08x]  comp_val 0x%08x\n",
-			   dmae->opcode, dmae->src_addr_lo >> 2,
-			   dmae->len, dmae->comp_addr_hi, dmae->comp_addr_lo,
-			   dmae->comp_val);
-		break;
-	}
-
-}
 
 /* copy command into DMAE command memory and set DMAE command go */
 void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae, int idx)
@@ -500,8 +439,6 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 	dmae.dst_addr_hi = 0;
 	dmae.len = len32;
 
-	bnx2x_dp_dmae(bp, &dmae, BNX2X_MSG_OFF);
-
 	/* issue the command and wait for completion */
 	bnx2x_issue_dmae_with_comp(bp, &dmae);
 }
@@ -534,8 +471,6 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 	dmae.dst_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_data));
 	dmae.len = len32;
 
-	bnx2x_dp_dmae(bp, &dmae, BNX2X_MSG_OFF);
-
 	/* issue the command and wait for completion */
 	bnx2x_issue_dmae_with_comp(bp, &dmae);
 }
@@ -556,27 +491,6 @@ static void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
 	bnx2x_write_dmae(bp, phys_addr + offset, addr + offset, len);
 }
 
-/* used only for slowpath so not inlined */
-static void bnx2x_wb_wr(struct bnx2x *bp, int reg, u32 val_hi, u32 val_lo)
-{
-	u32 wb_write[2];
-
-	wb_write[0] = val_hi;
-	wb_write[1] = val_lo;
-	REG_WR_DMAE(bp, reg, wb_write, 2);
-}
-
-#ifdef USE_WB_RD
-static u64 bnx2x_wb_rd(struct bnx2x *bp, int reg)
-{
-	u32 wb_data[2];
-
-	REG_RD_DMAE(bp, reg, wb_data, 2);
-
-	return HILO_U64(wb_data[0], wb_data[1]);
-}
-#endif
-
 static int bnx2x_mc_assert(struct bnx2x *bp)
 {
 	char last_idx;
@@ -6634,13 +6548,16 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 static void bnx2x_ilt_wr(struct bnx2x *bp, u32 index, dma_addr_t addr)
 {
 	int reg;
+	u32 wb_write[2];
 
 	if (CHIP_IS_E1(bp))
 		reg = PXP2_REG_RQ_ONCHIP_AT + index*8;
 	else
 		reg = PXP2_REG_RQ_ONCHIP_AT_B0 + index*8;
 
-	bnx2x_wb_wr(bp, reg, ONCHIP_ADDR1(addr), ONCHIP_ADDR2(addr));
+	wb_write[0] = ONCHIP_ADDR1(addr);
+	wb_write[1] = ONCHIP_ADDR2(addr);
+	REG_WR_DMAE(bp, reg, wb_write, 2);
 }
 
 static inline void bnx2x_igu_clear_sb(struct bnx2x *bp, u8 idu_sb_id)
-- 
1.7.9.rc2
