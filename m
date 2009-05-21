From: =?UTF-8?Q?Micha=C5=82=20Miros=C5=82aw=20?=
	<mirq-linux@rere.qmqm.pl>
Subject: [PATCH 3/6 2.6.30-rc6] ipvs: Use genl_register_family_with_ops()
Date: Thu, 21 May 2009 22:34:05 +0200 (CEST)
Message-ID: <3-1000-10527-1242938044-3360@rere.qmqm.pl>
References: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48067 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755237AbZEUUeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 16:34:04 -0400
In-Reply-To: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use genl_register_family_with_ops() instead of a copy.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

diff -urN linux-orig-mqbr/net/netfilter/ipvs/ip_vs_ctl.c linux-mqbr/net=
/netfilter/ipvs/ip_vs_ctl.c
--- linux-orig-mqbr/net/netfilter/ipvs/ip_vs_ctl.c	2009-03-24 00:12:14.=
000000000 +0100
+++ linux-mqbr/net/netfilter/ipvs/ip_vs_ctl.c	2009-05-21 17:54:36.00000=
0000 +0200
@@ -3345,22 +3345,8 @@
=20
 static int __init ip_vs_genl_register(void)
 {
-	int ret, i;
-
-	ret =3D genl_register_family(&ip_vs_genl_family);
-	if (ret)
-		return ret;
-
-	for (i =3D 0; i < ARRAY_SIZE(ip_vs_genl_ops); i++) {
-		ret =3D genl_register_ops(&ip_vs_genl_family, &ip_vs_genl_ops[i]);
-		if (ret)
-			goto err_out;
-	}
-	return 0;
-
-err_out:
-	genl_unregister_family(&ip_vs_genl_family);
-	return ret;
+	return genl_register_family_with_ops(&ip_vs_genl_family,
+		ip_vs_genl_ops, ARRAY_SIZE(ip_vs_genl_ops));
 }
=20
 static void ip_vs_genl_unregister(void)
