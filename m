From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rcx] prism54 Bug - Fix frequency
	reporting
Date: Wed, 11 Aug 2004 12:25:24 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200408111225.24892.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_UQfGBXIA8cfDmWa"
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


--Boundary-00=_UQfGBXIA8cfDmWa
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-08-11 Margit Schubert-While <margitsw@t-online.de>

* prism54_get_freq is incorrectly returning channel
* and not frequency. Wireless tools detect this, but
* other programs do not, leading to insane reported
* values. (As Jean documents, drivers should really be
* reporting the frequency).
* An example is wavemon.

Margit













--Boundary-00=_UQfGBXIA8cfDmWa
Content-Type: text/x-diff;
  charset="us-ascii";
  name="frequency.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="frequency.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-11 12:05:55.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-11 12:06:21.000000000 +0200
@@ -334,9 +334,10 @@
 	int rvalue;
 
 	rvalue = mgt_get_request(priv, DOT11_OID_CHANNEL, 0, NULL, &r);
-
+	fwrq->i = r.u;
+	rvalue |= mgt_get_request(priv, DOT11_OID_FREQUENCY, 0, NULL, &r);
 	fwrq->m = r.u;
-	fwrq->e = 0;
+	fwrq->e = 3;
 
 	return rvalue;
 }

--Boundary-00=_UQfGBXIA8cfDmWa
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_UQfGBXIA8cfDmWa--
