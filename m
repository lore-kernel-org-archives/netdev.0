From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc1] prism54 Fix initialization with older firmware
Date: Thu, 22 Jul 2004 10:27:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407221027.33023.margitsw__34705.7419516661$1090494856$gmane$org@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_0p3/AQCrJ6m8A6H"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_0p3/AQCrJ6m8A6H
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-07-22 Margit Schubert-While <margitsw@t-online.de>

* In the card initialization routine, we try to set the
  output power. For firmware < 1.0.4.3, this leads to a
  worrying "mgt_commit has failed .." in the log although
  the device continues to react normally.
  Fix is simple, do not try to configure output power.
  (which I believe we should not be doing anyway as it is 
   probably against local country regulations)

Margit



--Boundary-00=_0p3/AQCrJ6m8A6H
Content-Type: text/x-diff;
  charset="us-ascii";
  name="outputpow.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="outputpow.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.8-04/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c	2004-07-15 17:21:42.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/oid_mgt.c	2004-07-22 09:50:20.000000000 +0200
@@ -613,7 +613,9 @@
 	DOT11_OID_DEFKEYID,
 	DOT11_OID_DOT1XENABLE,
 	OID_INL_DOT11D_CONFORMANCE,
+	/* Do not initialize this - fw < 1.0.4.3 rejects it
 	OID_INL_OUTPUTPOWER,
+	*/
 };
 
 /* update the MAC addr. */

--Boundary-00=_0p3/AQCrJ6m8A6H--
