From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 1/5] Phonet: error on broadcast sending (unimplemented)
Date: Tue, 15 Sep 2009 14:32:19 +0300
Message-ID: <1253014343-20326-1-git-send-email-remi@remlab.net>
References: <a9972d3fe3d2bf09387bee7827b571c0@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:59537 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753062AbZIOLcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 07:32:20 -0400
In-Reply-To: <a9972d3fe3d2bf09387bee7827b571c0@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

---
 include/linux/phonet.h |    1 +
 net/phonet/af_phonet.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 1ef5a07..e5126cf 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -38,6 +38,7 @@
 #define PNPIPE_IFINDEX		2
=20
 #define PNADDR_ANY		0
+#define PNADDR_BROADCAST	0xFC
 #define PNPORT_RESOURCE_ROUTING	0
=20
 /* Values for PNPIPE_ENCAP option */
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index a662e62..f60c0c2 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -168,6 +168,12 @@ static int pn_send(struct sk_buff *skb, struct net=
_device *dev,
 		goto drop;
 	}
=20
+	/* Broadcast sending is not implemented */
+	if (pn_addr(dst) =3D=3D PNADDR_BROADCAST) {
+		err =3D -EOPNOTSUPP;
+		goto drop;
+	}
+
 	skb_reset_transport_header(skb);
 	WARN_ON(skb_headroom(skb) & 1); /* HW assumes word alignment */
 	skb_push(skb, sizeof(struct phonethdr));
--=20
1.6.0.4

