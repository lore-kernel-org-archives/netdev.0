From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc1] prism54 Fix wrong type for
	BSSID
Date: Mon, 12 Jul 2004 21:08:16 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407122108.16380.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_gGu8Ak2HayVVLag"
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


--Boundary-00=_gGu8Ak2HayVVLag
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-07-12 Margit Schubert-While <margitsw@t-online.de>

* The OID type for BSSID was incorrectly set to type SSID.
  It should be type RAW. This lead to interesting reporting
  by "iwpriv ethX g_bssid". 
  (Which caused garbage output and possibly an out of bound)

* Be ultra-cautious in reporting SSID by changing the "%s"
  to "%.*s" and passing the length. (Prompted by the false
  type above, whereby length = 0 and a %s on a garbage field)

Jeff, this is on top of the previous patch (chanfreq.patch)
from 2004/07/06 (which isn't in 2.6.8-rc1).

Margit







--Boundary-00=_gGu8Ak2HayVVLag
Content-Type: text/x-diff;
  charset="us-ascii";
  name="bssid.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="bssid.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.8-02/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c	2004-07-06 17:26:44.000000000 +0200
+++ linux-2.6.8-02/drivers/net/wireless/prism54/oid_mgt.c	2004-07-12 21:05:22.000000000 +0200
@@ -62,7 +62,7 @@
 
 	/* 802.11 */
 	OID_U32_C(DOT11_OID_BSSTYPE, 0x10000000),
-	OID_STRUCT_C(DOT11_OID_BSSID, 0x10000001, u8[6], OID_TYPE_SSID),
+	OID_STRUCT_C(DOT11_OID_BSSID, 0x10000001, u8[6], OID_TYPE_RAW),
 	OID_STRUCT_C(DOT11_OID_SSID, 0x10000002, struct obj_ssid,
 		     OID_TYPE_SSID),
 	OID_U32(DOT11_OID_STATE, 0x10000003),
@@ -770,8 +770,9 @@
 	case OID_TYPE_SSID:{
 			struct obj_ssid *ssid = r->ptr;
 			return snprintf(str, PRIV_STR_SIZE,
-					"length=%u\noctets=%s\n",
-					ssid->length, ssid->octets);
+					"length=%u\noctets=%.*s\n",
+					ssid->length, ssid->length,
+					ssid->octets);
 		}
 		break;
 	case OID_TYPE_KEY:{

--Boundary-00=_gGu8Ak2HayVVLag
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_gGu8Ak2HayVVLag--
