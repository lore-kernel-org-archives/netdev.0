From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.7-bk19] prism54 freq to channel
	incorrect for 5GHz
Date: Tue, 6 Jul 2004 17:38:07 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407061738.07098.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_fds6AERV+ss4GMa"
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


--Boundary-00=_fds6AERV+ss4GMa
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-07-06 Margit Schubert-While <margitsw@t-online.de>

* The frequency to channel conversion is wrong for the 5GHz band
* Although the (known) devices don't/can't use it,
  they do report it. (iwlist ethX freq)

Margit



--Boundary-00=_fds6AERV+ss4GMa
Content-Type: text/x-diff;
  charset="us-ascii";
  name="chanfreq.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="chanfreq.patch"

diff -Naur linux-2.6.7-02/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.7-03/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.7-02/drivers/net/wireless/prism54/oid_mgt.c	2004-07-01 07:23:52.000000000 +0200
+++ linux-2.6.7-03/drivers/net/wireless/prism54/oid_mgt.c	2004-07-06 17:26:44.000000000 +0200
@@ -28,10 +28,6 @@
 	2447, 2452, 2457, 2462, 2467, 2472, 2484
 };
 
-const int frequency_list_a[] = { 5170, 5180, 5190, 5200, 5210, 5220, 5230,
-	5240, 5260, 5280, 5300, 5320
-};
-
 int
 channel_of_freq(int f)
 {
@@ -41,10 +37,8 @@
 		while ((c < 14) && (f != frequency_list_bg[c]))
 			c++;
 		return (c >= 14) ? 0 : ++c;
-	} else if ((f >= (int) 5170) && (f <= (int) 5320)) {
-		while ((c < 12) && (f != frequency_list_a[c]))
-			c++;
-		return (c >= 12) ? 0 : (c + 37);
+	} else if ((f >= (int) 5000) && (f <= (int) 6000)) {
+		return ( (f - 5000) / 5 );
 	} else
 		return 0;
 }

--Boundary-00=_fds6AERV+ss4GMa
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_fds6AERV+ss4GMa--
