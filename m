From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rcx] prism54 Code cleanup
Date: Mon, 16 Aug 2004 17:03:57 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200408161703.58124.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_dzMIBzhQ2+RTzJZ"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_dzMIBzhQ2+RTzJZ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-08-16 Margit Schubert-While <margitsw@t-online.de>

This brings the kernel driver into line with CVS.
(Patches submitted by Denis Vlasenko)
There are neither functionality changes nor bug fixes.

* 2004-08-14 Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
* Move assignment out of if()
* Remove trailing space from printk
* Eliminate not needed local 'u32 reg'
* Add a comment about undoc bits
* Add #define VEC_SIZE, use it as appropriate
* Add some printks to reset error code path (our
* current area of trouble)
* Make printk text less confusing
* Some not needed NULL assignments removed
* mgt_commit_list(): tell which oid has failed

Jeff, patch goes on top of backed up patches.

Margit













--Boundary-00=_dzMIBzhQ2+RTzJZ
Content-Type: text/x-diff;
  charset="us-ascii";
  name="codeclean.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="codeclean.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/isl_38xx.c linux-2.6.8-04/drivers/net/wireless/prism54/isl_38xx.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/isl_38xx.c	2004-07-27 19:42:33.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/isl_38xx.c	2004-08-16 12:04:33.000000000 +0200
@@ -135,8 +135,8 @@
 		      readl(device_base + ISL38XX_CTRL_STAT_REG));
 		udelay(ISL38XX_WRITEIO_DELAY);
 
-		if (reg = readl(device_base + ISL38XX_INT_IDENT_REG),
-		    reg == 0xabadface) {
+		reg = readl(device_base + ISL38XX_INT_IDENT_REG);
+		if (reg == 0xabadface) {
 #if VERBOSE > SHOW_ERROR_MESSAGES
 			do_gettimeofday(&current_time);
 			DEBUG(SHOW_TRACING,
@@ -194,10 +194,8 @@
 void
 isl38xx_interface_reset(void *device_base, dma_addr_t host_address)
 {
-	u32 reg;
-
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx_interface_reset \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "isl38xx_interface_reset\n");
 #endif
 
 	/* load the address of the control block in the device */
@@ -205,8 +203,7 @@
 	udelay(ISL38XX_WRITEIO_DELAY);
 
 	/* set the reset bit in the Device Interrupt Register */
-	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_RESET,
-			  ISL38XX_DEV_INT_REG);
+	isl38xx_w32_flush(device_base, ISL38XX_DEV_INT_RESET, ISL38XX_DEV_INT_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);
 
 	/* enable the interrupt for detecting initialization */
@@ -214,9 +211,7 @@
 	/* Note: Do not enable other interrupts here. We want the
 	 * device to have come up first 100% before allowing any other 
 	 * interrupts. */
-	reg = ISL38XX_INT_IDENT_INIT;
-
-	isl38xx_w32_flush(device_base, reg, ISL38XX_INT_EN_REG);
+	isl38xx_w32_flush(device_base, ISL38XX_INT_IDENT_INIT, ISL38XX_INT_EN_REG);
 	udelay(ISL38XX_WRITEIO_DELAY);  /* allow complete full reset */
 }
 
diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/isl_38xx.h linux-2.6.8-04/drivers/net/wireless/prism54/isl_38xx.h
--- linux-2.6.8-01/drivers/net/wireless/prism54/isl_38xx.h	2004-07-27 19:42:33.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/isl_38xx.h	2004-08-16 12:04:30.000000000 +0200
@@ -95,6 +95,10 @@
 #define ISL38XX_INT_SOURCES                     0x001E
 
 /* Control/Status register bits */
+/* Looks like there are other meaningful bits
+    0x20004400 seen in normal operation,
+    0x200044db at 'timeout waiting for mgmt response'
+*/
 #define ISL38XX_CTRL_STAT_SLEEPMODE             0x00000200
 #define	ISL38XX_CTRL_STAT_CLKRUN		0x00800000
 #define ISL38XX_CTRL_STAT_RESET                 0x10000000
diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-16 12:01:53.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-16 12:04:33.000000000 +0200
@@ -1947,7 +1947,7 @@
 		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	struct islpci_mgmtframe *response = NULL;
+	struct islpci_mgmtframe *response;
 	int ret = -EIO;
 
 	printk("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
@@ -1983,7 +1983,7 @@
 		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	struct islpci_mgmtframe *response = NULL;
+	struct islpci_mgmtframe *response;
 	int ret = 0, response_op = PIMFOR_OP_ERROR;
 
 	printk("%s: set_oid 0x%08X\tlen: %d\n", ndev->name, priv->priv_oid,
diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.8-04/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/islpci_dev.c	2004-08-06 11:40:52.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/islpci_dev.c	2004-08-16 16:42:49.000000000 +0200
@@ -375,8 +375,6 @@
 	u32 rc;
 	islpci_private *priv = netdev_priv(ndev);
 
-	printk(KERN_DEBUG "%s: islpci_open()\n", ndev->name);
-
 	/* reset data structures, upload firmware and reset device */
 	rc = islpci_reset(priv,1);
 	if (rc) {
@@ -462,8 +460,7 @@
 		return rc;
 	}
 
-	printk(KERN_DEBUG
-	       "%s: firmware uploaded done, now triggering reset...\n",
+	printk(KERN_DEBUG "%s: firmware upload complete\n",
 	       priv->ndev->name);
 
 	islpci_set_state(priv, PRV_STATE_POSTBOOT);
@@ -499,15 +496,16 @@
 		/* If we're here it's because our IRQ hasn't yet gone through. 
 		 * Retry a bit more...
 		 */
-		 printk(KERN_ERR "%s: device soft reset timed out\n",
-		       priv->ndev->name);
-
+		printk(KERN_ERR "%s: reset problem: no 'reset complete' IRQ seen\n",
+			priv->ndev->name);
 	}
 
 	finish_wait(&priv->reset_done, &wait);
 
-	if(result)
+	if (result) {
+		printk(KERN_ERR "%s: islpci_reset_if: failure\n", priv->ndev->name);
 		return result;
+	}
 
 	islpci_set_state(priv, PRV_STATE_INIT);
 
@@ -524,6 +522,7 @@
 
 	islpci_set_state(priv, PRV_STATE_READY);
 
+	printk(KERN_DEBUG "%s: interface reset complete\n", priv->ndev->name);
 	return 0;
 }
 
@@ -584,18 +583,18 @@
 	/* now that the data structures are cleaned up, upload
 	 * firmware and reset interface */
 		rc = islpci_upload_fw(priv);
-		if (rc) 
+		if (rc) {
+			printk(KERN_ERR "%s: islpci_reset: failure\n",
+				priv->ndev->name);
 			return rc;
+		}
 	}
 
 	/* finally reset interface */
 	rc = islpci_reset_if(priv);
-	if (!rc) /* If successful */
-		return rc;
-	
-	printk(KERN_DEBUG  "prism54: Your card/socket may be faulty, or IRQ line too busy :(\n");
+	if (rc)
+		printk(KERN_ERR "prism54: Your card/socket may be faulty, or IRQ line too busy :(\n");
 	return rc;
-
 }
 
 struct net_device_stats *
@@ -604,7 +603,7 @@
 	islpci_private *priv = netdev_priv(ndev);
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics \n");
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_statistics\n");
 #endif
 
 	return &priv->statistics;
diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/islpci_eth.c linux-2.6.8-04/drivers/net/wireless/prism54/islpci_eth.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/islpci_eth.c	2004-07-27 19:42:33.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/islpci_eth.c	2004-08-16 12:04:33.000000000 +0200
@@ -508,11 +508,12 @@
 	/* increment the transmit error counter */
 	statistics->tx_errors++;
 
+	printk(KERN_WARNING "%s: tx_timeout", ndev->name);
 	if (!priv->reset_task_pending) {
 		priv->reset_task_pending = 1;
+		printk(", scheduling a reset");
 		netif_stop_queue(ndev);
 		schedule_work(&priv->reset_task);
 	}
-
-	return;
+	printk("\n");
 }
diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.8-04/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c	2004-08-10 10:52:08.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/oid_mgt.c	2004-08-16 12:04:33.000000000 +0200
@@ -555,15 +555,18 @@
 		u32 oid = t->oid;
 		BUG_ON(data == NULL);
 		while (j <= t->range) {
-			response = NULL;
-			ret |= islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
+			int r = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
 						      oid, data, t->size,
 						      &response);
 			if (response) {
-				ret |= (response->header->operation ==
-					PIMFOR_OP_ERROR);
+				r |= (response->header->operation == PIMFOR_OP_ERROR);
 				islpci_mgt_release(response);
 			}
+			if (r)
+				printk(KERN_ERR "%s: mgt_commit_list: failure. "
+					"oid=%08x err=%d\n",
+					priv->ndev->name, oid, r);
+			ret |= r;
 			j++;
 			oid++;
 			data += t->size;
@@ -624,7 +627,7 @@
 static int
 mgt_update_addr(islpci_private *priv)
 {
-	struct islpci_mgmtframe *res = NULL;
+	struct islpci_mgmtframe *res;
 	int ret;
 
 	ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
@@ -638,9 +641,13 @@
 	if (res)
 		islpci_mgt_release(res);
 
+	if (ret)
+		printk(KERN_ERR "%s: mgt_update_addr: failure\n", priv->ndev->name);
 	return ret;
 }
 
+#define VEC_SIZE(a) (sizeof(a)/sizeof(a[0]))
+
 void
 mgt_commit(islpci_private *priv)
 {
@@ -650,14 +657,10 @@
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return;
 
-	rvalue = mgt_commit_list(priv, commit_part1,
-				 sizeof (commit_part1) /
-				 sizeof (commit_part1[0]));
+	rvalue = mgt_commit_list(priv, commit_part1, VEC_SIZE(commit_part1));
 
 	if (priv->iw_mode != IW_MODE_MONITOR)
-		rvalue |= mgt_commit_list(priv, commit_part2,
-					  sizeof (commit_part2) /
-					  sizeof (commit_part2[0]));
+		rvalue |= mgt_commit_list(priv, commit_part2, VEC_SIZE(commit_part2));
 
 	u = OID_INL_MODE;
 	rvalue |= mgt_commit_list(priv, &u, 1);
@@ -666,8 +669,7 @@
 	if (rvalue) {
 		/* some request have failed. The device might be in an
 		   incoherent state. We should reset it ! */
-		printk(KERN_DEBUG "%s: mgt_commit has failed. Restart the "
-		       "device \n", priv->ndev->name);
+		printk(KERN_DEBUG "%s: mgt_commit: failure\n", priv->ndev->name);
 	}
 }
 

--Boundary-00=_dzMIBzhQ2+RTzJZ
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_dzMIBzhQ2+RTzJZ--
