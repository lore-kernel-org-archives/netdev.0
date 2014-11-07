From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 2/3] cxgb4: Cleanup macros so they follow the same style and look consistent
Date: Fri,  7 Nov 2014 09:35:24 +0530
Message-ID: <1415333125-10635-3-git-send-email-hariprasad@chelsio.com>
References: <1415333125-10635-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, hch@infradead.org,
	swise@opengridcomputing.com, leedom@chelsio.com, anish@chelsio.com,
	praveenm@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1415333125-10635-1-git-send-email-hariprasad@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Various patches have ended up changing the style of the symbolic macros/register
to different style.

As a result, the current kernel.org files are a mix of different macro styles.
Since this macro/register defines is used by different drivers a
few patch series have ended up adding duplicate macro/register define entries
with different styles. This makes these register define/macro files a complete
mess and we want to make them clean and consistent. This patch cleans up a part
of it.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
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
index e86b5fe..c98a350 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -128,30 +128,30 @@ int t4_setup_debugfs(struct adapter *adap)
 			  t4_debugfs_files,
 			  ARRAY_SIZE(t4_debugfs_files));
 
-	i = t4_read_reg(adap, MA_TARGET_MEM_ENABLE);
-	if (i & EDRAM0_ENABLE) {
-		size = t4_read_reg(adap, MA_EDRAM0_BAR);
-		add_debugfs_mem(adap, "edc0", MEM_EDC0, EDRAM_SIZE_GET(size));
+	i = t4_read_reg(adap, MA_TARGET_MEM_ENABLE_A);
+	if (i & EDRAM0_ENABLE_F) {
+		size = t4_read_reg(adap, MA_EDRAM0_BAR_A);
+		add_debugfs_mem(adap, "edc0", MEM_EDC0, EDRAM0_SIZE_G(size));
 	}
-	if (i & EDRAM1_ENABLE) {
-		size = t4_read_reg(adap, MA_EDRAM1_BAR);
-		add_debugfs_mem(adap, "edc1", MEM_EDC1, EDRAM_SIZE_GET(size));
+	if (i & EDRAM1_ENABLE_F) {
+		size = t4_read_reg(adap, MA_EDRAM1_BAR_A);
+		add_debugfs_mem(adap, "edc1", MEM_EDC1, EDRAM1_SIZE_G(size));
 	}
 	if (is_t4(adap->params.chip)) {
-		size = t4_read_reg(adap, MA_EXT_MEMORY_BAR);
-		if (i & EXT_MEM_ENABLE)
+		size = t4_read_reg(adap, MA_EXT_MEMORY_BAR_A);
+		if (i & EXT_MEM_ENABLE_F)
 			add_debugfs_mem(adap, "mc", MEM_MC,
-					EXT_MEM_SIZE_GET(size));
+					EXT_MEM_SIZE_G(size));
 	} else {
-		if (i & EXT_MEM_ENABLE) {
-			size = t4_read_reg(adap, MA_EXT_MEMORY_BAR);
+		if (i & EXT_MEM0_ENABLE_F) {
+			size = t4_read_reg(adap, MA_EXT_MEMORY0_BAR_A);
 			add_debugfs_mem(adap, "mc0", MEM_MC0,
-					EXT_MEM_SIZE_GET(size));
+					EXT_MEM0_SIZE_G(size));
 		}
-		if (i & EXT_MEM1_ENABLE) {
-			size = t4_read_reg(adap, MA_EXT_MEMORY1_BAR);
+		if (i & EXT_MEM1_ENABLE_F) {
+			size = t4_read_reg(adap, MA_EXT_MEMORY1_BAR_A);
 			add_debugfs_mem(adap, "mc1", MEM_MC1,
-					EXT_MEM_SIZE_GET(size));
+					EXT_MEM1_SIZE_G(size));
 		}
 	}
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 172f68b..a2d6e50 100644
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
+	size = t4_read_reg(adap, MA_EDRAM0_BAR_A);
+	edc0_size = EDRAM0_SIZE_G(size) << 20;
+	size = t4_read_reg(adap, MA_EDRAM1_BAR_A);
+	edc1_size = EDRAM1_SIZE_G(size) << 20;
+	size = t4_read_reg(adap, MA_EXT_MEMORY0_BAR_A);
+	mc0_size = EXT_MEM0_SIZE_G(size) << 20;
 
 	edc0_end = edc0_size;
 	edc1_end = edc0_end + edc1_size;
@@ -3838,9 +3841,8 @@ int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte)
 			/* T4 only has a single memory channel */
 			goto err;
 		} else {
-			mc1_size = EXT_MEM_SIZE_GET(
-					t4_read_reg(adap,
-						    MA_EXT_MEMORY1_BAR)) << 20;
+			size = t4_read_reg(adap, MA_EXT_MEMORY1_BAR_A);
+			mc1_size = EXT_MEM1_SIZE_G(size) << 20;
 			mc1_end = mc0_end + mc1_size;
 			if (offset < mc1_end) {
 				memtype = MEM_MC1;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index a9d9d74..945fd14 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -483,12 +483,12 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 	 * MEM_MC0  = 2 -- For T5
 	 * MEM_MC1  = 3 -- For T5
 	 */
-	edc_size  = EDRAM_SIZE_GET(t4_read_reg(adap, MA_EDRAM0_BAR));
+	edc_size  = EDRAM0_SIZE_G(t4_read_reg(adap, MA_EDRAM0_BAR_A));
 	if (mtype != MEM_MC1)
 		memoffset = (mtype * (edc_size * 1024 * 1024));
 	else {
-		mc_size = EXT_MEM_SIZE_GET(t4_read_reg(adap,
-						       MA_EXT_MEMORY_BAR));
+		mc_size = EXT_MEM0_SIZE_G(t4_read_reg(adap,
+						      MA_EXT_MEMORY1_BAR_A));
 		memoffset = (MEM_MC0 * edc_size + mc_size) * 1024 * 1024;
 	}
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index a1024db..c8eb7ba 100644
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
+#define MA_EDRAM0_BAR_A 0x77c0
+
+#define EDRAM0_SIZE_S    0
+#define EDRAM0_SIZE_M    0xfffU
+#define EDRAM0_SIZE_V(x) ((x) << EDRAM0_SIZE_S)
+#define EDRAM0_SIZE_G(x) (((x) >> EDRAM0_SIZE_S) & EDRAM0_SIZE_M)
+
+#define MA_EDRAM1_BAR_A 0x77c4
+
+#define EDRAM1_SIZE_S    0
+#define EDRAM1_SIZE_M    0xfffU
+#define EDRAM1_SIZE_V(x) ((x) << EDRAM1_SIZE_S)
+#define EDRAM1_SIZE_G(x) (((x) >> EDRAM1_SIZE_S) & EDRAM1_SIZE_M)
+
+#define MA_EXT_MEMORY_BAR_A 0x77c8
+
+#define EXT_MEM_SIZE_S    0
+#define EXT_MEM_SIZE_M    0xfffU
+#define EXT_MEM_SIZE_V(x) ((x) << EXT_MEM_SIZE_S)
+#define EXT_MEM_SIZE_G(x) (((x) >> EXT_MEM_SIZE_S) & EXT_MEM_SIZE_M)
+
+#define MA_EXT_MEMORY1_BAR_A 0x7808
+
+#define EXT_MEM1_SIZE_S    0
+#define EXT_MEM1_SIZE_M    0xfffU
+#define EXT_MEM1_SIZE_V(x) ((x) << EXT_MEM1_SIZE_S)
+#define EXT_MEM1_SIZE_G(x) (((x) >> EXT_MEM1_SIZE_S) & EXT_MEM1_SIZE_M)
+
+#define MA_EXT_MEMORY0_BAR_A 0x77c8
+
+#define EXT_MEM0_SIZE_S    0
+#define EXT_MEM0_SIZE_M    0xfffU
+#define EXT_MEM0_SIZE_V(x) ((x) << EXT_MEM0_SIZE_S)
+#define EXT_MEM0_SIZE_G(x) (((x) >> EXT_MEM0_SIZE_S) & EXT_MEM0_SIZE_M)
+
+#define MA_TARGET_MEM_ENABLE_A 0x77d8
+
+#define EXT_MEM_ENABLE_S    2
+#define EXT_MEM_ENABLE_V(x) ((x) << EXT_MEM_ENABLE_S)
+#define EXT_MEM_ENABLE_F    EXT_MEM_ENABLE_V(1U)
+
+#define EDRAM1_ENABLE_S    1
+#define EDRAM1_ENABLE_V(x) ((x) << EDRAM1_ENABLE_S)
+#define EDRAM1_ENABLE_F    EDRAM1_ENABLE_V(1U)
+
+#define EDRAM0_ENABLE_S    0
+#define EDRAM0_ENABLE_V(x) ((x) << EDRAM0_ENABLE_S)
+#define EDRAM0_ENABLE_F    EDRAM0_ENABLE_V(1U)
+
+#define EXT_MEM1_ENABLE_S    4
+#define EXT_MEM1_ENABLE_V(x) ((x) << EXT_MEM1_ENABLE_S)
+#define EXT_MEM1_ENABLE_F    EXT_MEM1_ENABLE_V(1U)
+
+#define EXT_MEM0_ENABLE_S    2
+#define EXT_MEM0_ENABLE_V(x) ((x) << EXT_MEM0_ENABLE_S)
+#define EXT_MEM0_ENABLE_F    EXT_MEM0_ENABLE_V(1U)
 
 #define MA_INT_CAUSE 0x77e0
 #define  MEM_PERR_INT_CAUSE 0x00000002U
@@ -532,7 +573,6 @@
 #define MA_PARITY_ERROR_STATUS 0x77f4
 #define MA_PARITY_ERROR_STATUS2 0x7804
 
-#define MA_EXT_MEMORY1_BAR 0x7808
 #define EDC_0_BASE_ADDR 0x7900
 
 #define EDC_BIST_CMD 0x7904
diff --git a/drivers/scsi/csiostor/csio_hw_t4.c b/drivers/scsi/csiostor/csio_hw_t4.c
index 89ecbac..95d8318 100644
--- a/drivers/scsi/csiostor/csio_hw_t4.c
+++ b/drivers/scsi/csiostor/csio_hw_t4.c
@@ -307,12 +307,12 @@ csio_t4_memory_rw(struct csio_hw *hw, u32 win, int mtype, u32 addr,
 	 * MEM_EDC1 = 1
 	 * MEM_MC   = 2 -- T4
 	 */
-	edc_size  = EDRAM_SIZE_GET(csio_rd_reg32(hw, MA_EDRAM0_BAR));
+	edc_size  = EDRAM0_SIZE_G(csio_rd_reg32(hw, MA_EDRAM0_BAR_A));
 	if (mtype != MEM_MC1)
 		memoffset = (mtype * (edc_size * 1024 * 1024));
 	else {
-		mc_size = EXT_MEM_SIZE_GET(csio_rd_reg32(hw,
-							 MA_EXT_MEMORY_BAR));
+		mc_size = EXT_MEM_SIZE_G(csio_rd_reg32(hw,
+						       MA_EXT_MEMORY_BAR_A));
 		memoffset = (MEM_MC0 * edc_size + mc_size) * 1024 * 1024;
 	}
 
@@ -383,11 +383,12 @@ static void
 csio_t4_dfs_create_ext_mem(struct csio_hw *hw)
 {
 	u32 size;
-	int i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE);
-	if (i & EXT_MEM_ENABLE) {
-		size = csio_rd_reg32(hw, MA_EXT_MEMORY_BAR);
+	int i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE_A);
+
+	if (i & EXT_MEM_ENABLE_F) {
+		size = csio_rd_reg32(hw, MA_EXT_MEMORY_BAR_A);
 		csio_add_debugfs_mem(hw, "mc", MEM_MC,
-				     EXT_MEM_SIZE_GET(size));
+				     EXT_MEM_SIZE_G(size));
 	}
 }
 
diff --git a/drivers/scsi/csiostor/csio_hw_t5.c b/drivers/scsi/csiostor/csio_hw_t5.c
index 27745c1..66e180a 100644
--- a/drivers/scsi/csiostor/csio_hw_t5.c
+++ b/drivers/scsi/csiostor/csio_hw_t5.c
@@ -298,12 +298,12 @@ csio_t5_memory_rw(struct csio_hw *hw, u32 win, int mtype, u32 addr,
 	 * MEM_MC0  = 2 -- For T5
 	 * MEM_MC1  = 3 -- For T5
 	 */
-	edc_size  = EDRAM_SIZE_GET(csio_rd_reg32(hw, MA_EDRAM0_BAR));
+	edc_size  = EDRAM0_SIZE_G(csio_rd_reg32(hw, MA_EDRAM0_BAR_A));
 	if (mtype != MEM_MC1)
 		memoffset = (mtype * (edc_size * 1024 * 1024));
 	else {
-		mc_size = EXT_MEM_SIZE_GET(csio_rd_reg32(hw,
-							 MA_EXT_MEMORY_BAR));
+		mc_size = EXT_MEM_SIZE_G(csio_rd_reg32(hw,
+						       MA_EXT_MEMORY_BAR_A));
 		memoffset = (MEM_MC0 * edc_size + mc_size) * 1024 * 1024;
 	}
 
@@ -372,16 +372,17 @@ static void
 csio_t5_dfs_create_ext_mem(struct csio_hw *hw)
 {
 	u32 size;
-	int i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE);
-	if (i & EXT_MEM_ENABLE) {
-		size = csio_rd_reg32(hw, MA_EXT_MEMORY_BAR);
+	int i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE_A);
+
+	if (i & EXT_MEM_ENABLE_F) {
+		size = csio_rd_reg32(hw, MA_EXT_MEMORY_BAR_A);
 		csio_add_debugfs_mem(hw, "mc0", MEM_MC0,
-				     EXT_MEM_SIZE_GET(size));
+				     EXT_MEM_SIZE_G(size));
 	}
-	if (i & EXT_MEM1_ENABLE) {
-		size = csio_rd_reg32(hw, MA_EXT_MEMORY1_BAR);
+	if (i & EXT_MEM1_ENABLE_F) {
+		size = csio_rd_reg32(hw, MA_EXT_MEMORY1_BAR_A);
 		csio_add_debugfs_mem(hw, "mc1", MEM_MC1,
-				     EXT_MEM_SIZE_GET(size));
+				     EXT_MEM_SIZE_G(size));
 	}
 }
 
diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
index 17794ad..70e1eb6 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -128,10 +128,10 @@ static int csio_setup_debugfs(struct csio_hw *hw)
 	if (IS_ERR_OR_NULL(hw->debugfs_root))
 		return -1;
 
-	i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE);
-	if (i & EDRAM0_ENABLE)
+	i = csio_rd_reg32(hw, MA_TARGET_MEM_ENABLE_A);
+	if (i & EDRAM0_ENABLE_F)
 		csio_add_debugfs_mem(hw, "edc0", MEM_EDC0, 5);
-	if (i & EDRAM1_ENABLE)
+	if (i & EDRAM1_ENABLE_F)
 		csio_add_debugfs_mem(hw, "edc1", MEM_EDC1, 5);
 
 	hw->chip_ops->chip_dfs_create_ext_mem(hw);
-- 
1.7.1

