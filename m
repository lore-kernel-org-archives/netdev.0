From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 11/14] Phonet: provide MAC header operations
Date: Tue, 16 Sep 2008 18:08:11 +0300
Message-ID: <1221577694-4513-11-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:52829 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825AbYIPPI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:08:29 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF8AVw031651
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 18:08:27 +0300
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/if_phonet.h |    2 ++
 net/phonet/af_phonet.c    |   29 +++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_phonet.h b/include/linux/if_phonet.h
index 22df25f..94bc59b 100644
--- a/include/linux/if_phonet.h
+++ b/include/linux/if_phonet.h
@@ -12,3 +12,5 @@
 /* 6 bytes header + 65535 bytes payload */
 #define PHONET_MAX_MTU		65541
 #define PHONET_DEV_MTU		PHONET_MAX_MTU
+
+extern struct header_ops phonet_header_ops;
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index ec99413..2593d9c 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -101,6 +101,35 @@ static struct net_proto_family phonet_proto_family=
 =3D {
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

