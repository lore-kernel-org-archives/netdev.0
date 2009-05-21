From: =?UTF-8?Q?Micha=C5=82=20Miros=C5=82aw=20?=
	<mirq-linux@rere.qmqm.pl>
Subject: [PATCH 4/6 2.6.30-rc6] netlabel: Use genl_register_family_with_ops()
Date: Thu, 21 May 2009 22:34:05 +0200 (CEST)
Message-ID: <4-1000-10527-1242938044-3360@rere.qmqm.pl>
References: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48068 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755242AbZEUUeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 16:34:05 -0400
In-Reply-To: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use genl_register_family_with_ops() instead of a copy. This fixes genet=
link
family leak on error path.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

diff -urN linux-orig-mqbr/net/netlabel/netlabel_cipso_v4.c linux-mqbr/n=
et/netlabel/netlabel_cipso_v4.c
--- linux-orig-mqbr/net/netlabel/netlabel_cipso_v4.c	2009-03-24 00:12:1=
4.000000000 +0100
+++ linux-mqbr/net/netlabel/netlabel_cipso_v4.c	2009-05-21 17:53:22.000=
000000 +0200
@@ -785,18 +785,6 @@
  */
 int __init netlbl_cipsov4_genl_init(void)
 {
-	int ret_val, i;
-
-	ret_val =3D genl_register_family(&netlbl_cipsov4_gnl_family);
-	if (ret_val !=3D 0)
-		return ret_val;
-
-	for (i =3D 0; i < ARRAY_SIZE(netlbl_cipsov4_ops); i++) {
-		ret_val =3D genl_register_ops(&netlbl_cipsov4_gnl_family,
-				&netlbl_cipsov4_ops[i]);
-		if (ret_val !=3D 0)
-			return ret_val;
-	}
-
-	return 0;
+	return genl_register_family_with_ops(&netlbl_cipsov4_gnl_family,
+		netlbl_cipsov4_ops, ARRAY_SIZE(netlbl_cipsov4_ops));
 }
diff -urN linux-orig-mqbr/net/netlabel/netlabel_mgmt.c linux-mqbr/net/n=
etlabel/netlabel_mgmt.c
--- linux-orig-mqbr/net/netlabel/netlabel_mgmt.c	2009-03-24 00:12:14.00=
0000000 +0100
+++ linux-mqbr/net/netlabel/netlabel_mgmt.c	2009-05-21 17:53:46.0000000=
00 +0200
@@ -779,18 +779,6 @@
  */
 int __init netlbl_mgmt_genl_init(void)
 {
-	int ret_val, i;
-
-	ret_val =3D genl_register_family(&netlbl_mgmt_gnl_family);
-	if (ret_val !=3D 0)
-		return ret_val;
-
-	for (i =3D 0; i < ARRAY_SIZE(netlbl_mgmt_genl_ops); i++) {
-		ret_val =3D genl_register_ops(&netlbl_mgmt_gnl_family,
-				&netlbl_mgmt_genl_ops[i]);
-		if (ret_val !=3D 0)
-			return ret_val;
-	}
-
-	return 0;
+	return genl_register_family_with_ops(&netlbl_mgmt_gnl_family,
+		netlbl_mgmt_genl_ops, ARRAY_SIZE(netlbl_mgmt_genl_ops));
 }
diff -urN linux-orig-mqbr/net/netlabel/netlabel_unlabeled.c linux-mqbr/=
net/netlabel/netlabel_unlabeled.c
--- linux-orig-mqbr/net/netlabel/netlabel_unlabeled.c	2009-03-24 00:12:=
14.000000000 +0100
+++ linux-mqbr/net/netlabel/netlabel_unlabeled.c	2009-05-21 17:49:53.00=
0000000 +0200
@@ -1478,20 +1478,8 @@
  */
 int __init netlbl_unlabel_genl_init(void)
 {
-	int ret_val, i;
-
-	ret_val =3D genl_register_family(&netlbl_unlabel_gnl_family);
-	if (ret_val !=3D 0)
-		return ret_val;
-
-	for (i =3D 0; i < ARRAY_SIZE(netlbl_unlabel_genl_ops); i++) {
-		ret_val =3D genl_register_ops(&netlbl_unlabel_gnl_family,
-				&netlbl_unlabel_genl_ops[i]);
-		if (ret_val !=3D 0)
-			return ret_val;
-	}
-
-	return 0;
+	return genl_register_family_with_ops(&netlbl_unlabel_gnl_family,
+		netlbl_unlabel_genl_ops, ARRAY_SIZE(netlbl_unlabel_genl_ops));
 }
=20
 /*
