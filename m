From: =?UTF-8?Q?Micha=C5=82=20Miros=C5=82aw=20?=
	<mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Subject: [PATCH 6/6 2.6.30-rc6] wireless: Use genl_register_family_with_ops()
Date: Thu, 21 May 2009 22:34:06 +0200 (CEST)
Message-ID: <6-1000-10527-1242938044-3360@rere.qmqm.pl>
References: <1-1000-10527-1242938044-3360@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1-1000-10527-1242938044-3360-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use genl_register_family_with_ops() instead of a copy.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>

diff -urN linux-orig-mqbr/net/wireless/nl80211.c linux-mqbr/net/wireles=
s/nl80211.c
--- linux-orig-mqbr/net/wireless/nl80211.c	2009-03-24 00:12:14.00000000=
0 +0100
+++ linux-mqbr/net/wireless/nl80211.c	2009-05-21 17:51:34.000000000 +02=
00
@@ -3395,18 +3395,13 @@
=20
 int nl80211_init(void)
 {
-	int err, i;
+	int err;
=20
-	err =3D genl_register_family(&nl80211_fam);
+	err =3D genl_register_family_with_ops(&nl80211_fam,
+		nl80211_ops, ARRAY_SIZE(nl80211_ops));
 	if (err)
 		return err;
=20
-	for (i =3D 0; i < ARRAY_SIZE(nl80211_ops); i++) {
-		err =3D genl_register_ops(&nl80211_fam, &nl80211_ops[i]);
-		if (err)
-			goto err_out;
-	}
