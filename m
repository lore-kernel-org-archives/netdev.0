From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rcx] prism54 Fix supported rates
	reporting
Date: Tue, 10 Aug 2004 13:34:06 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200408101334.07020.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_uKLGBVHJg8OD85r"
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


--Boundary-00=_uKLGBVHJg8OD85r
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-08-10 Margit Schubert-While <margitsw@t-online.de>
* We are not correctly reporting supported bit rates.
* Fix it.

Margit













--Boundary-00=_uKLGBVHJg8OD85r
Content-Type: text/x-diff;
  charset="us-ascii";
  name="supprates.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="supprates.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-10 10:52:08.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-10 13:21:03.000000000 +0200
@@ -436,7 +436,7 @@
 {
 	struct iw_range *range = (struct iw_range *) extra;
 	islpci_private *priv = netdev_priv(ndev);
-	char *data;
+	u8 *data;
 	int i, m, rvalue;
 	struct obj_frequencies *freq;
 	union oid_res_t r;
@@ -513,8 +513,7 @@
 	i = 0;
 	while ((i < IW_MAX_BITRATES) && (*data != 0)) {
 		/*       the result must be in bps. The card gives us 500Kbps */
-		range->bitrate[i] = (__s32) (*data >> 1);
-		range->bitrate[i] *= 1000000;
+		range->bitrate[i] = *data * 500000;
 		i++;
 		data++;
 	}

--Boundary-00=_uKLGBVHJg8OD85r
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_uKLGBVHJg8OD85r--
