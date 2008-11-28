From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 1/3] niu: use net_device_stats nowadays available in net_device
Date: Fri, 28 Nov 2008 19:53:36 +0200
Message-ID: <12278948183224-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55102 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbYK1Rxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 12:53:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/niu.c |   16 ++++++++--------
 drivers/net/niu.h |    1 -
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2f98f7a..022866d 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6078,10 +6078,10 @@ static void niu_get_rx_stats(struct niu *np)
 		dropped +=3D rp->rx_dropped;
 		errors +=3D rp->rx_errors;
 	}
-	np->net_stats.rx_packets =3D pkts;
-	np->net_stats.rx_bytes =3D bytes;
-	np->net_stats.rx_dropped =3D dropped;
-	np->net_stats.rx_errors =3D errors;
+	np->dev->stats.rx_packets =3D pkts;
+	np->dev->stats.rx_bytes =3D bytes;
+	np->dev->stats.rx_dropped =3D dropped;
+	np->dev->stats.rx_errors =3D errors;
 }
=20
 static void niu_get_tx_stats(struct niu *np)
@@ -6097,9 +6097,9 @@ static void niu_get_tx_stats(struct niu *np)
 		bytes +=3D rp->tx_bytes;
 		errors +=3D rp->tx_errors;
 	}
-	np->net_stats.tx_packets =3D pkts;
-	np->net_stats.tx_bytes =3D bytes;
-	np->net_stats.tx_errors =3D errors;
+	np->dev->stats.tx_packets =3D pkts;
+	np->dev->stats.tx_bytes =3D bytes;
+	np->dev->stats.tx_errors =3D errors;
 }
=20
 static struct net_device_stats *niu_get_stats(struct net_device *dev)
@@ -6109,7 +6109,7 @@ static struct net_device_stats *niu_get_stats(str=
uct net_device *dev)
 	niu_get_rx_stats(np);
 	niu_get_tx_stats(np);
=20
-	return &np->net_stats;
+	return &dev->stats;
 }
=20
 static void niu_load_hash_xmac(struct niu *np, u16 *hash)
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index cf449aa..e1a7392 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -3249,7 +3249,6 @@ struct niu {
 	spinlock_t			lock;
=20
 	const struct niu_ops		*ops;
-	struct net_device_stats		net_stats;
 	union niu_mac_stats		mac_stats;
=20
 	struct rx_ring_info		*rx_rings;
--=20
1.5.2.2

