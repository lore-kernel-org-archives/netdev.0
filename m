From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 8/9][ATM]: [lanai] quiet sparse warnings
Date: Mon, 07 Mar 2005 17:07:49 -0500
Message-ID: <200503072207.j27M7nAJ021016@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/07 15:26:27-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [lanai] quiet sparse warnings
#       
#   Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/lanai.c
#   2005/03/07 15:26:10-05:00 chas@relax.cmf.nrl.navy.mil +9 -9
#   [ATM]: [lanai] quiet sparse warnings
#   
#   Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	2005-03-07 15:36:36 -05:00
+++ b/drivers/atm/lanai.c	2005-03-07 15:36:36 -05:00
@@ -650,7 +650,7 @@
 	enum lanai_vcc_offset offset)
 {
 	u32 val;
-	APRINTK(lvcc->vbase != 0, "cardvcc_read: unbound vcc!\n");
+	APRINTK(lvcc->vbase != NULL, "cardvcc_read: unbound vcc!\n");
 	val= readl(lvcc->vbase + offset);
 	RWDEBUG("VR vci=%04d 0x%02X = 0x%08X\n",
 	    lvcc->vci, (int) offset, val);
@@ -660,7 +660,7 @@
 static inline void cardvcc_write(const struct lanai_vcc *lvcc,
 	u32 val, enum lanai_vcc_offset offset)
 {
-	APRINTK(lvcc->vbase != 0, "cardvcc_write: unbound vcc!\n");
+	APRINTK(lvcc->vbase != NULL, "cardvcc_write: unbound vcc!\n");
 	APRINTK((val & ~0xFFFF) == 0,
 	    "cardvcc_write: bad val 0x%X (vci=%d, addr=0x%02X)\n",
 	    (unsigned int) val, lvcc->vci, (unsigned int) offset);
@@ -748,7 +748,7 @@
 /* Shutdown receiving on card */
 static void lanai_shutdown_rx_vci(const struct lanai_vcc *lvcc)
 {
-	if (lvcc->vbase == 0)		/* We were never bound to a VCI */
+	if (lvcc->vbase == NULL)	/* We were never bound to a VCI */
 		return;
 	/* 15.1.1 - set to trashing, wait one cell time (15us) */
 	cardvcc_write(lvcc,
@@ -779,7 +779,7 @@
 	int read, write, lastread = -1;
 	APRINTK(!in_interrupt(),
 	    "lanai_shutdown_tx_vci called w/o process context!\n");
-	if (lvcc->vbase == 0)		/* We were never bound to a VCI */
+	if (lvcc->vbase == NULL)	/* We were never bound to a VCI */
 		return;
 	/* 15.2.1 - wait for queue to drain */
 	while ((skb = skb_dequeue(&lvcc->tx.backlog)) != NULL)
@@ -1544,7 +1544,7 @@
 static inline void host_vcc_bind(struct lanai_dev *lanai,
 	struct lanai_vcc *lvcc, vci_t vci)
 {
-	if (lvcc->vbase != 0)
+	if (lvcc->vbase != NULL)
 		return;    /* We already were bound in the other direction */
 	DPRINTK("Binding vci %d\n", vci);
 #ifdef USE_POWERDOWN
@@ -1562,7 +1562,7 @@
 static inline void host_vcc_unbind(struct lanai_dev *lanai,
 	struct lanai_vcc *lvcc)
 {
-	if (lvcc->vbase == 0)
+	if (lvcc->vbase == NULL)
 		return;	/* This vcc was never bound */
 	DPRINTK("Unbinding vci %d\n", lvcc->vci);
 	lvcc->vbase = NULL;
@@ -2179,7 +2179,7 @@
 		goto error;
 	raw_base = lanai->pci->resource[0].start;
 	lanai->base = (bus_addr_t) ioremap(raw_base, LANAI_MAPPING_SIZE);
-	if (lanai->base == 0) {
+	if (lanai->base == NULL) {
 		printk(KERN_ERR DEV_LABEL ": couldn't remap I/O space\n");
 		goto error_pci;
 	}
@@ -2333,7 +2333,7 @@
 	}
 	if (lvcc->tx.atmvcc == atmvcc) {
 		if (atmvcc == lanai->cbrvcc) {
-			if (lvcc->vbase != 0)
+			if (lvcc->vbase != NULL)
 				lanai_cbr_shutdown(lanai);
 			lanai->cbrvcc = NULL;
 		}
@@ -2524,7 +2524,7 @@
 	struct lanai_vcc *lvcc = (struct lanai_vcc *) atmvcc->dev_data;
 	struct lanai_dev *lanai = (struct lanai_dev *) atmvcc->dev->dev_data;
 	unsigned long flags;
-	if (unlikely(lvcc == NULL || lvcc->vbase == 0 ||
+	if (unlikely(lvcc == NULL || lvcc->vbase == NULL ||
 	      lvcc->tx.atmvcc != atmvcc))
 		goto einval;
 #ifdef DEBUG
