From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 08/11] Phonet: provide MAC header operations
Date: Mon, 22 Sep 2008 18:47:22 +0300
Message-ID: <1222098445-26175-8-git-send-email-remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:34627 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbYIVPrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:47:45 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFlIhb008928
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 10:47:43 -0500
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/if_phonet.h |    4 ++++
 net/phonet/af_phonet.c    |   29 +++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_phonet.h b/include/linux/if_phonet.h
index 22df25f..7e98921 100644
--- a/include/linux/if_phonet.h
+++ b/include/linux/if_phonet.h
@@ -12,3 +12,7 @@
 /* 6 bytes header + 65535 bytes payload */
 #define PHONET_MAX_MTU		65541
 #define PHONET_DEV_MTU		PHONET_MAX_MTU
+
+#ifdef __KERNEL__
+extern struct header_ops phonet_header_ops;
+#endif
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index e6771d3..51397ff 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -99,6 +99,35 @@ static struct net_proto_family phonet_proto_family =3D=
 {
 	.owner =3D THIS_MODULE,
 };
=20
+/* Phonet device header operations */
+static int pn_header_create(struct sk_buff *skb, struct net_device *de=
v,
+				unsigned short type, const void *daddr,
+				const void *saddr, unsigned len)
+{
+	u8 *media =3D skb_push(skb, 1);
+
+	if (type !=3D ETH_P_PHONET)
+		return -1;
+
+	if (!saddr)
+		saddr =3D dev->dev_addr;
+	*media =3D *(const u8 *)saddr;
+	return 1;
+}
+
+static int pn_header_parse(const struct sk_buff *skb, unsigned char *h=
addr)
+{
+	const u8 *media =3D skb_mac_header(skb);
+	*haddr =3D *media;
+	return 1;
+}
+
+struct header_ops phonet_header_ops =3D {
+	.create =3D pn_header_create,
+	.parse =3D pn_header_parse,
+};
+EXPORT_SYMBOL(phonet_header_ops);
+
 /*
  * Prepends an ISI header and sends a datagram.
  */
--=20
1.5.4.3

