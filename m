From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH v3 1/7] fsl/fman: move struct fman to header file
Date: Thu, 24 Aug 2017 10:28:22 +0300
Message-ID: <1503559708-13405-2-git-send-email-madalin.bucur@nxp.com>
References: <1503559708-13405-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503559708-13405-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman.c | 74 ------------------------------
 drivers/net/ethernet/freescale/fman/fman.h | 73 +++++++++++++++++++++++++++++
 2 files changed, 73 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index e714b8f..6ed383f 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -564,80 +564,6 @@ struct fman_cfg {
 	u32 qmi_def_tnums_thresh;
 };
 
-/* Structure that holds information received from device tree */
-struct fman_dts_params {
-	void __iomem *base_addr;		/* FMan virtual address */
-	struct resource *res;			/* FMan memory resource */
-	u8 id;					/* FMan ID */
-
-	int err_irq;				/* FMan Error IRQ */
-
-	u16 clk_freq;				/* FMan clock freq (In Mhz) */
-
-	u32 qman_channel_base;			/* QMan channels base */
-	u32 num_of_qman_channels;		/* Number of QMan channels */
-
-	struct resource muram_res;		/* MURAM resource */
-};
-
-/** fman_exceptions_cb
- * fman		- Pointer to FMan
- * exception	- The exception.
- *
- * Exceptions user callback routine, will be called upon an exception
- * passing the exception identification.
- *
- * Return: irq status
- */
-typedef irqreturn_t (fman_exceptions_cb)(struct fman *fman,
-					 enum fman_exceptions exception);
-
-/** fman_bus_error_cb
- * fman		- Pointer to FMan
- * port_id	- Port id
- * addr		- Address that caused the error
- * tnum		- Owner of error
- * liodn	- Logical IO device number
- *
- * Bus error user callback routine, will be called upon bus error,
- * passing parameters describing the errors and the owner.
- *
- * Return: IRQ status
- */
-typedef irqreturn_t (fman_bus_error_cb)(struct fman *fman, u8 port_id,
-					u64 addr, u8 tnum, u16 liodn);
-
-struct fman {
-	struct device *dev;
-	void __iomem *base_addr;
-	struct fman_intr_src intr_mng[FMAN_EV_CNT];
-
-	struct fman_fpm_regs __iomem *fpm_regs;
-	struct fman_bmi_regs __iomem *bmi_regs;
-	struct fman_qmi_regs __iomem *qmi_regs;
-	struct fman_dma_regs __iomem *dma_regs;
-	struct fman_hwp_regs __iomem *hwp_regs;
-	fman_exceptions_cb *exception_cb;
-	fman_bus_error_cb *bus_error_cb;
-	/* Spinlock for FMan use */
-	spinlock_t spinlock;
-	struct fman_state_struct *state;
-
-	struct fman_cfg *cfg;
-	struct muram_info *muram;
-	/* cam section in muram */
-	unsigned long cam_offset;
-	size_t cam_size;
-	/* Fifo in MURAM */
-	unsigned long fifo_offset;
-	size_t fifo_size;
-
-	u32 liodn_base[64];
-	u32 liodn_offset[64];
-
-	struct fman_dts_params dts_params;
-};
-
 static irqreturn_t fman_exceptions(struct fman *fman,
 				   enum fman_exceptions exception)
 {
diff --git a/drivers/net/ethernet/freescale/fman/fman.h b/drivers/net/ethernet/freescale/fman/fman.h
index f53e147..6745065 100644
--- a/drivers/net/ethernet/freescale/fman/fman.h
+++ b/drivers/net/ethernet/freescale/fman/fman.h
@@ -274,6 +274,79 @@ struct fman_intr_src {
 	void *src_handle;
 };
 
+/** fman_exceptions_cb
+ * fman         - Pointer to FMan
+ * exception    - The exception.
+ *
+ * Exceptions user callback routine, will be called upon an exception
+ * passing the exception identification.
+ *
+ * Return: irq status
+ */
+typedef irqreturn_t (fman_exceptions_cb)(struct fman *fman,
+					 enum fman_exceptions exception);
+/** fman_bus_error_cb
+ * fman         - Pointer to FMan
+ * port_id      - Port id
+ * addr         - Address that caused the error
+ * tnum         - Owner of error
+ * liodn        - Logical IO device number
+ *
+ * Bus error user callback routine, will be called upon bus error,
+ * passing parameters describing the errors and the owner.
+ *
+ * Return: IRQ status
+ */
+typedef irqreturn_t (fman_bus_error_cb)(struct fman *fman, u8 port_id,
+					u64 addr, u8 tnum, u16 liodn);
+
+/* Structure that holds information received from device tree */
+struct fman_dts_params {
+	void __iomem *base_addr;                /* FMan virtual address */
+	struct resource *res;                   /* FMan memory resource */
+	u8 id;                                  /* FMan ID */
+
+	int err_irq;                            /* FMan Error IRQ */
+
+	u16 clk_freq;                           /* FMan clock freq (In Mhz) */
+
+	u32 qman_channel_base;                  /* QMan channels base */
+	u32 num_of_qman_channels;               /* Number of QMan channels */
+
+	struct resource muram_res;              /* MURAM resource */
+};
+
+struct fman {
+	struct device *dev;
+	void __iomem *base_addr;
+	struct fman_intr_src intr_mng[FMAN_EV_CNT];
+
+	struct fman_fpm_regs __iomem *fpm_regs;
+	struct fman_bmi_regs __iomem *bmi_regs;
+	struct fman_qmi_regs __iomem *qmi_regs;
+	struct fman_dma_regs __iomem *dma_regs;
+	struct fman_hwp_regs __iomem *hwp_regs;
+	fman_exceptions_cb *exception_cb;
+	fman_bus_error_cb *bus_error_cb;
+	/* Spinlock for FMan use */
+	spinlock_t spinlock;
+	struct fman_state_struct *state;
+
+	struct fman_cfg *cfg;
+	struct muram_info *muram;
+	/* cam section in muram */
+	unsigned long cam_offset;
+	size_t cam_size;
+	/* Fifo in MURAM */
+	unsigned long fifo_offset;
+	size_t fifo_size;
+
+	u32 liodn_base[64];
+	u32 liodn_offset[64];
+
+	struct fman_dts_params dts_params;
+};
+
 /* Structure for port-FM communication during fman_port_init. */
 struct fman_port_init_params {
 	u8 port_id;			/* port Id */
-- 
2.1.0
