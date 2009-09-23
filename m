From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: error on broadcast sending (unimplemented)
Date: Wed, 23 Sep 2009 16:17:11 +0300
Message-ID: <1253711831-7947-2-git-send-email-remi@remlab.net>
References: <1253711831-7947-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:54406 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769AbZIWNRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 09:17:08 -0400
In-Reply-To: <1253711831-7947-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

If we ever implement this, then we can stop returning an error.

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

