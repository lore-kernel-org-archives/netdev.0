From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 2/2] net: verify GSO flag bits against netdev features
Date: Thu, 17 Nov 2011 01:05:33 +0100 (CET)
Message-ID: <d4513ed885d62d13873f9b7310fc20cbfa55f634.1321488025.git.mirq-linux@rere.qmqm.pl>
References: <2ec988cd27c6eb5162ea2e41416edcaae207bb5e.1321488025.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:35143 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753810Ab1KQAFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 19:05:36 -0500
In-Reply-To: <2ec988cd27c6eb5162ea2e41416edcaae207bb5e.1321488025.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/netdevice.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b35ffd7..31da3bb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2492,6 +2492,15 @@ netdev_features_t netif_skb_features(struct sk_b=
uff *skb);
 static inline int net_gso_ok(netdev_features_t features, int gso_type)
 {
 	netdev_features_t feature =3D gso_type << NETIF_F_GSO_SHIFT;
+
+	/* check flags correspondence */
+	BUILD_BUG_ON(SKB_GSO_TCPV4   !=3D (NETIF_F_TSO >> NETIF_F_GSO_SHIFT))=
;
+	BUILD_BUG_ON(SKB_GSO_UDP     !=3D (NETIF_F_UFO >> NETIF_F_GSO_SHIFT))=
;
+	BUILD_BUG_ON(SKB_GSO_DODGY   !=3D (NETIF_F_GSO_ROBUST >> NETIF_F_GSO_=
SHIFT));
+	BUILD_BUG_ON(SKB_GSO_TCP_ECN !=3D (NETIF_F_TSO_ECN >> NETIF_F_GSO_SHI=
=46T));
+	BUILD_BUG_ON(SKB_GSO_TCPV6   !=3D (NETIF_F_TSO6 >> NETIF_F_GSO_SHIFT)=
);
+	BUILD_BUG_ON(SKB_GSO_FCOE    !=3D (NETIF_F_FSO >> NETIF_F_GSO_SHIFT))=
;
+
 	return (features & feature) =3D=3D feature;
 }
=20
--=20
1.7.7.1
