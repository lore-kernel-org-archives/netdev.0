From: =?UTF-8?Q?Micha=C5=82=20Miros=C5=82aw=20?=
	<mirq-linux@rere.qmqm.pl>
Subject: [PATCH 2/6 2.6.30-rc6] irda: Use genl_register_family_with_ops()
Date: Thu, 21 May 2009 22:34:04 +0200 (CEST)
Message-ID: <2-1000-10527-1242938044-3360@rere.qmqm.pl>
References: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Samuel Ortiz <samuel@sortiz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48066 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754986AbZEUUeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 16:34:04 -0400
In-Reply-To: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use genl_register_family_with_ops() instead of a copy.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Cc: Samuel Ortiz <samuel@sortiz.org>

diff -urN linux-orig-mqbr/net/irda/irnetlink.c linux-mqbr/net/irda/irne=
tlink.c
--- linux-orig-mqbr/net/irda/irnetlink.c	2009-03-24 00:12:14.000000000 =
+0100
+++ linux-mqbr/net/irda/irnetlink.c	2009-05-21 17:47:31.000000000 +0200
@@ -148,21 +148,8 @@
=20
 int irda_nl_register(void)
 {
-	int err, i;
-
-	err =3D genl_register_family(&irda_nl_family);
-	if (err)
-		return err;
-
-	for (i =3D 0; i < ARRAY_SIZE(irda_nl_ops); i++) {
-		err =3D genl_register_ops(&irda_nl_family, &irda_nl_ops[i]);
-		if (err)
-			goto err_out;
-	}
-	return 0;
- err_out:
-	genl_unregister_family(&irda_nl_family);
-	return err;
+	return genl_register_family_with_ops(&irda_nl_family,
+		irda_nl_ops, ARRAY_SIZE(irda_nl_ops));
 }
=20
 void irda_nl_unregister(void)
