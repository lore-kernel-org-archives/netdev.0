From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc1] prism54 Fix null pointer
	reference (Bug 100)
Date: Mon, 26 Jul 2004 15:10:45 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407261510.45615.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_VLQBB+T1w2GWG9d"
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


--Boundary-00=_VLQBB+T1w2GWG9d
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-07-22 Margit Schubert-While <margitsw@t-online.de>

* prism54_get/set_debug_oid are missing checks for a null pointer.
  Reported in Bugzilla number 100.

Margit





--Boundary-00=_VLQBB+T1w2GWG9d
Content-Type: text/x-diff;
  charset="us-ascii";
  name="bugptr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="bugptr.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-07-01 07:23:52.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c	2004-07-26 10:35:17.000000000 +0200
@@ -1942,7 +1942,7 @@
 {
 	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_mgmtframe *response = NULL;
-	int ret = -EIO, response_op = PIMFOR_OP_ERROR;
+	int ret = -EIO;
 
 	printk("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
 	data->length = 0;
@@ -1952,9 +1952,7 @@
 		    islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
 					   priv->priv_oid, extra, 256,
 					   &response);
-		response_op = response->header->operation;
 		printk("%s: ret: %i\n", ndev->name, ret);
-		printk("%s: response_op: %i\n", ndev->name, response_op);
 		if (ret || !response
 		    || response->header->operation == PIMFOR_OP_ERROR) {
 			if (response) {
@@ -1991,16 +1989,20 @@
 					   priv->priv_oid, extra, data->length,
 					   &response);
 		printk("%s: ret: %i\n", ndev->name, ret);
+		if (ret || !response
+		    || response->header->operation == PIMFOR_OP_ERROR) {
+			if (response) {
+				islpci_mgt_release(response);
+			}
+			printk("%s: EIO\n", ndev->name);
+			ret = -EIO;
+		}
 		if (!ret) {
 			response_op = response->header->operation;
 			printk("%s: response_op: %i\n", ndev->name,
 			       response_op);
 			islpci_mgt_release(response);
 		}
-		if (ret || response_op == PIMFOR_OP_ERROR) {
-			printk("%s: EIO\n", ndev->name);
-			ret = -EIO;
-		}
 	}
 
 	return (ret ? ret : -EINPROGRESS);

--Boundary-00=_VLQBB+T1w2GWG9d
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_VLQBB+T1w2GWG9d--
