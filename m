From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 2/3] cxgb4: Cleanup macros to match the HW generated one
Date: Mon,  3 Nov 2014 17:46:53 +0530
Message-ID: <1415017014-12701-3-git-send-email-hariprasad@chelsio.com>
References: <1415017014-12701-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	praveenm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415017014-12701-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   32 +++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   16 +++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   72 +++++++++++++++-----
 drivers/scsi/csiostor/csio_hw_t4.c                 |   15 ++--
 drivers/scsi/csiostor/csio_hw_t5.c                 |   21 +++---
 drivers/scsi/csiostor/csio_init.c                  |    6 +-
 7 files changed, 106 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index e86b5fe..aa75c91 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -128,30 +128,30 @@ int t4_setup_debugfs(struct adapter *adap)
 			  t4_debugfs_files,
 			  ARRAY_SIZE(t4_debugfs_files));
 
-	i = t4_read_reg(adap, MA_TARGET_MEM_ENABLE);
-	if (i & EDRAM0_ENABLE) {
-		size = t4_read_reg(adap, MA_EDRAM0_BAR);
-		add_debugfs_mem(adap, "edc0", MEM_EDC0, EDRAM_SIZE_GET(size));
+	i = t4_read_reg(adap, A_MA_TARGET_MEM_ENABLE);
+	if (i & F_EDRAM0_ENABLE) {
+		size = t4_read_reg(adap, A_MA_EDRAM0_BAR);
+		add_debugfs_mem(adap, "edc0", MEM_EDC0, G_EDRAM0_SIZE(size));
 	}
-	if (i & EDRAM1_ENABLE) {
-		size = t4_read_reg(adap, MA_EDRAM1_BAR);
-		add_debugfs_mem(adap, "edc1", MEM_EDC1, EDRAM_SIZE_GET(size));
+	if (i & F_EDRAM1_ENABLE) {
+		size = t4_read_reg(adap, A_MA_EDRAM1_BAR);
+		add_debugfs_mem(adap, "edc1", MEM_EDC1, G_EDRAM1_SIZE(size));
 	}
 	if (is_t4(adap->params.chip)) {
-		size = t4_read_reg(adap, MA_EXT_MEMORY_BAR);
-		if (i & EXT_MEM_ENABLE)
+		size = t4_read_reg(adap, A_MA_EXT_MEMORY_BAR);
+		if (i & F_EXT_MEM_ENABLE)
 			add_debugfs_mem(adap, "mc", MEM_MC,
-					EXT_MEM_SIZE_GET(size));
+					G_EXT_MEM_SIZE(size));
 	} else {
-		if (i & EXT_MEM_ENABLE) {
-			size = t4_read_reg(adap, MA_EXT_MEMORY_BAR);
+		if (i & F_EXT_MEM0_ENABLE) {
+			size = t4_read_reg(adap, A_MA_EXT_MEMORY0_BAR);
 			add_debugfs_mem(adap, "mc0", MEM_MC0,
-					EXT_MEM_SIZE_GET(size));
+					G_EXT_MEM0_SIZE(size));
 		}
-		if (i & EXT_MEM1_ENABLE) {
-			size = t4_read_reg(adap, MA_EXT_MEMORY1_BAR);
+		if (i & F_EXT_MEM1_ENABLE) {
+			size = t4_read_reg(adap, A_MA_EXT_MEMORY1_BAR);
 			add_debugfs_mem(adap, "mc1", MEM_MC1,
-					EXT_MEM_SIZE_GET(size));
+					G_EXT_MEM1_SIZE(size));
 		}
 	}
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 172f68b..65ce937 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3802,7 +3802,7 @@ int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte)
 {
 	struct adapter *adap;
 	u32 offset, memtype, memaddr;
-	u32 edc0_size, edc1_size, mc0_size, mc1_size;
+	u32 edc0_size, edc1_size, mc0_size, mc1_size, size;
 	u32 edc0_end, edc1_end, mc0_end, mc1_end;
 	int ret;
 
@@ -3816,9 +3816,12 @@ int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte)
 	 * and EDC1.  Some cards will have neither MC0 nor MC1, most cards have
 	 * MC0, and some have both MC0 and MC1.
 	 */
-	edc0_size = EDRAM_SIZE_GET(t4_read_reg(adap, MA_EDRAM0_BAR)) << 20;
-	edc1_size = EDRAM_SIZE_GET(t4_read_reg(adap, MA_EDRAM1_BAR)) << 20;
-	mc0_size = EXT_MEM_SIZE_GET(t4_read_reg(adap, MA_EXT_MEMORY_BAR)) << 20;
+	size = t4_read_reg(adap, A_MA_EDRAM0_BAR);
+	edc0_size = G_EDRAM0_SIZE(size) << 20;
+	size = t4_read_reg(adap, A_MA_EDRAM1_BAR);
+	edc1_size = G_EDRAM1_SIZE(size) << 20;
+	size = t4_read_reg(adap, A_MA_EXT_MEMORY0_BAR);
+	mc0_size = G_EXT_MEM0_SIZE(size) << 20;
 
 	edc0_end = edc0_size;
 	edc1_end = edc0_end + edc1_size;
@@ -3838,9 +3841,8 @@ int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte)
 			/* T4 only has a single memory channel */
 			goto err;
 		} else {
-			mc1_size = EXT_MEM_SIZE_GET(
-					t4_read_reg(adap,
-						    MA_EXT_MEMORY1_BAR)) << 20;
+			size = t4_read_reg(adap, A_MA_EXT_MEMORY1_BAR);
+			mc1_size = G_EXT_MEM1_SIZE(size) << 20;
 			mc1_end = mc0_end + mc1_size;
 			if (offset < mc1_end) {
 				memtype = MEM_MC1;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index a9d9d74..0343e35 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -483,12 +483,12 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 	 * MEM_MC0  = 2 -- For T5
 	 * MEM_MC1  = 3 -- For T5
 	 */
-	edc_size  = EDRAM_SIZE_GET(t4_read_reg(adap, MA_EDRAM0_BAR));
+	edc_size  = G_EDRAM0_SIZE(t4_read_reg(adap, A_MA_EDRAM0_BAR));
 	if (mtype != MEM_MC1)
 		memoffset = (mtype * (edc_size * 1024 * 1024));
 	else {
-		mc_size = EXT_MEM_SIZE_GET(t4_read_reg(adap,
-						       MA_EXT_MEMORY_BAR));
+		mc_size = G_EXT_MEM0_SIZE(t4_read_reg(adap,
+						      A_MA_EXT_MEMORY1_BAR));
 		memoffset = (MEM_MC0 * edc_size + mc_size) * 1024 * 1024;
 	}
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index a1024db..6e30695 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -501,21 +501,62 @@
 
 #define MC_BIST_STATUS_RDATA 0x7688
 
-#define MA_EDRAM0_BAR 0x77c0
-#define MA_EDRAM1_BAR 0x77c4
-#define EDRAM_SIZE_MASK   0xfffU
-#define EDRAM_SIZE_GET(x) ((x) & EDRAM_SIZE_MASK)
-
-#define MA_EXT_MEMORY_BAR 0x77c8
-#define  EXT_MEM_SIZE_MASK   0x00000fffU
-#define  EXT_MEM_SIZE_SHIFT  0
-#define  EXT_MEM_SIZE_GET(x) (((x) & EXT_MEM_SIZE_MASK) >> EXT_MEM_SIZE_SHIFT)
-
-#define MA_TARGET_MEM_ENABLE 0x77d8
-#define  EXT_MEM1_ENABLE 0x00000010U
-#define  EXT_MEM_ENABLE 0x00000004U
-#define  EDRAM1_ENABLE  0x00000002U
-#define  EDRAM0_ENABLE  0x00000001U
+#define A_MA_EDRAM0_BAR 0x77c0
+
+#define S_EDRAM0_SIZE    0
+#define M_EDRAM0_SIZE    0xfffU
+#define V_EDRAM0_SIZE(x) ((x) << S_EDRAM0_SIZE)
+#define G_EDRAM0_SIZE(x) (((x) >> S_EDRAM0_SIZE) & M_EDRAM0_SIZE)
+
+#define A_MA_EDRAM1_BAR 0x77c4
+
+#define S_EDRAM1_SIZE    0
+#define M_EDRAM1_SIZE    0xfffU
+#define V_EDRAM1_SIZE(x) ((x) << S_EDRAM1_SIZE)
+#define G_EDRAM1_SIZE(x) (((x) >> S_EDRAM1_SIZE) & M_EDRAM1_SIZE)
+
+#define A_MA_EXT_MEMORY_BAR 0x77c8
+
+#define S_EXT_MEM_SIZE    0
+#define M_EXT_MEM_SIZE    0xfffU
+#define V_EXT_MEM_SIZE(x) ((x) << S_EXT_MEM_SIZE)
+#define G_EXT_MEM_SIZE(x) (((x) >> S_EXT_MEM_SIZE) & M_EXT_MEM_SIZE)
+
+#define A_MA_EXT_MEMORY1_BAR 0x7808
+
+#define S_EXT_MEM1_SIZE    0
+#define M_EXT_MEM1_SIZE    0xfffU
+#define V_EXT_MEM1_SIZE(x) ((x) << S_EXT_MEM1_SIZE)
+#define G_EXT_MEM1_SIZE(x) (((x) >> S_EXT_MEM1_SIZE) & M_EXT_MEM1_SIZE)
+
+#define A_MA_EXT_MEMORY0_BAR 0x77c8
+
+#define S_EXT_MEM0_SIZE    0
+#define M_EXT_MEM0_SIZE    0xfffU
+#define V_EXT_MEM0_SIZE(x) ((x) << S_EXT_MEM0_SIZE)
+#define G_EXT_MEM0_SIZE(x) (((x) >> S_EXT_MEM0_SIZE) & M_EXT_MEM0_SIZE)
+
+#define A_MA_TARGET_MEM_ENABLE 0x77d8
+
+#define S_EXT_MEM_ENABLE    2
+#define V_EXT_MEM_ENABLE(x) ((x) << S_EXT_MEM_ENABLE)
+#define F_EXT_MEM_ENABLE    V_EXT_MEM_ENABLE(1U)
+
+#define S_EDRAM1_ENABLE    1
+#define V_EDRAM1_ENABLE(x) ((x) << S_EDRAM1_ENABLE)
+#define F_EDRAM1_ENABLE    V_EDRAM1_ENABLE(1U)
+
+#define S_EDRAM0_ENABLE    0
+#define V_EDRAM0_ENABLE(x) ((x) << S_EDRAM0_ENABLE)
+#define F_EDRAM0_ENABLE    V_EDRAM0_ENABLE(1U)
+
+#define S_EXT_MEM1_ENABLE    4
+#define V_EXT_MEM1_ENABLE(x) ((x) << S_EXT_MEM1_ENABLE)
+#define F_EXT_MEM1_ENABLE    V_EXT_MEM1_ENABLE(1U)
+
+#define S_EXT_MEM0_ENABLE    2
+#define V_EXT_MEM0_ENABLE(x) ((x) << S_EXT_MEM0_ENABLE)
+#define F_EXT_MEM0_ENABLE    V_EXT_MEM0_ENABLE(1U)
 
 #define MA_INT_CAUSE 0x77e0
 #define  MEM_PERR_INT_CAUSE 0x00000002U
@@ -532,7 +573,6 @@
 #define MA_PARITY_ERROR_STATUS 0x77f4
 #define MA_PARITY_ERROR_STATUS2 0x7804
 
-#define MA_EXT_MEMORY1_BAR 0x7808
 #define EDC_0_BASE_ADDR 0x7900
 
 #define EDC_BIST_CMD 0x7904
diff --git a/drivers/scsi/csiostor/csio_hw_t4.c b/drivers/scsi/csiostor/csio_hw_t4.c
index 89ecbac..d83765d 100644
--- a/drivers/scsi/csiostor/csio_hw_t4.c
+++ b/drivers/scsi/csiostor/csio_hw_t4.c
@@ -307,12 +307,12 @@ csio_t4_memory_rw(struct csio_hw *hw, u32 win, int mtype, u32 addr,
 	 * MEM_EDC1 = 1
 	 * MEM_MC   = 2 -- T4
 	 */
-	edc_size  = EDRAM_SIZE_GET(csio_rd_reg32(hw, MA_EDRAM0_BAR));
+	edc_size  = G_EDRAM0_SIZE(csio_rd_reg32(hw, A_MA_EDRAM0_BAR));
 	if (mtype != MEM_MC1)
 		memoffset = (mtype * (edc_size * 1024 * 1024));
 	else {
-		mc_size = EXT_MEM_SIZE_GET(csio_rd_reg32(hw,
-							 MA_EXT_MEMORY_BAR));
+		mc_size = G_EXT_MEM_SIZE(csio_rd_reg32(hw,
+						       A_MA_EXT_MEMORY_BAR));
 		memoffset = (MEM_MC0 * edc_size + mc_size) * 1024 * 1024;
 	}
 
@@ -383,11 +383,12 @@ static void
 csio_t4_dfs_create_ext_mem(struct csio_hw *hw)
 {
 	u32 size;
-	int i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE);
-	if (i & EXT_MEM_ENABLE) {
-		size = csio_rd_reg32(hw, MA_EXT_MEMORY_BAR);
+	int i = csio_rd_reg32(hw, A_MA_TARGET_MEM_ENABLE);
+
+	if (i & F_EXT_MEM_ENABLE) {
+		size = csio_rd_reg32(hw, A_MA_EXT_MEMORY_BAR);
 		csio_add_debugfs_mem(hw, "mc", MEM_MC,
-				     EXT_MEM_SIZE_GET(size));
+				     G_EXT_MEM_SIZE(size));
 	}
 }
 
diff --git a/drivers/scsi/csiostor/csio_hw_t5.c b/drivers/scsi/csiostor/csio_hw_t5.c
index 27745c1..ab0ac9a 100644
--- a/drivers/scsi/csiostor/csio_hw_t5.c
+++ b/drivers/scsi/csiostor/csio_hw_t5.c
@@ -298,12 +298,12 @@ csio_t5_memory_rw(struct csio_hw *hw, u32 win, int mtype, u32 addr,
 	 * MEM_MC0  = 2 -- For T5
 	 * MEM_MC1  = 3 -- For T5
 	 */
-	edc_size  = EDRAM_SIZE_GET(csio_rd_reg32(hw, MA_EDRAM0_BAR));
+	edc_size  = G_EDRAM0_SIZE(csio_rd_reg32(hw, A_MA_EDRAM0_BAR));
 	if (mtype != MEM_MC1)
 		memoffset = (mtype * (edc_size * 1024 * 1024));
 	else {
-		mc_size = EXT_MEM_SIZE_GET(csio_rd_reg32(hw,
-							 MA_EXT_MEMORY_BAR));
+		mc_size = G_EXT_MEM_SIZE(csio_rd_reg32(hw,
+						       A_MA_EXT_MEMORY_BAR));
 		memoffset = (MEM_MC0 * edc_size + mc_size) * 1024 * 1024;
 	}
 
@@ -372,16 +372,17 @@ static void
 csio_t5_dfs_create_ext_mem(struct csio_hw *hw)
 {
 	u32 size;
-	int i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE);
-	if (i & EXT_MEM_ENABLE) {
-		size = csio_rd_reg32(hw, MA_EXT_MEMORY_BAR);
+	int i = csio_rd_reg32(hw, A_MA_TARGET_MEM_ENABLE);
+
+	if (i & F_EXT_MEM_ENABLE) {
+		size = csio_rd_reg32(hw, A_MA_EXT_MEMORY_BAR);
 		csio_add_debugfs_mem(hw, "mc0", MEM_MC0,
-				     EXT_MEM_SIZE_GET(size));
+				     G_EXT_MEM_SIZE(size));
 	}
-	if (i & EXT_MEM1_ENABLE) {
-		size = csio_rd_reg32(hw, MA_EXT_MEMORY1_BAR);
+	if (i & F_EXT_MEM1_ENABLE) {
+		size = csio_rd_reg32(hw, A_MA_EXT_MEMORY1_BAR);
 		csio_add_debugfs_mem(hw, "mc1", MEM_MC1,
-				     EXT_MEM_SIZE_GET(size));
+				     G_EXT_MEM_SIZE(size));
 	}
 }
 
diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
index 17794ad..757a406 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -128,10 +128,10 @@ static int csio_setup_debugfs(struct csio_hw *hw)
 	if (IS_ERR_OR_NULL(hw->debugfs_root))
 		return -1;
 
-	i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE);
-	if (i & EDRAM0_ENABLE)
+	i = csio_rd_reg32(hw, A_MA_TARGET_MEM_ENABLE);
+	if (i & F_EDRAM0_ENABLE)
 		csio_add_debugfs_mem(hw, "edc0", MEM_EDC0, 5);
-	if (i & EDRAM1_ENABLE)
+	if (i & F_EDRAM1_ENABLE)
 		csio_add_debugfs_mem(hw, "edc1", MEM_EDC1, 5);
 
 	hw->chip_ops->chip_dfs_create_ext_mem(hw);
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
