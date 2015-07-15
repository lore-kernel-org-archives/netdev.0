From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 09/12] can: esd_usb2: don't touch skb after netif_rx()
Date: Wed, 15 Jul 2015 09:09:46 +0200
Message-ID: <1436944189-26618-10-git-send-email-mkl@pengutronix.de>
References: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	=?UTF-8?q?Thomas=20K=C3=B6rper?= <thomas.koerper@esd.eu>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no guarantee that the skb is in the same state after calling
net_receive_skb() or netif_rx(). It might be freed or reused. Not reall=
y
harmful as its a read access, except you turn on the proper debugging o=
ptions
which catch a use after free.

Cc: Thomas K=C3=B6rper <thomas.koerper@esd.eu>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/esd_usb2.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_u=
sb2.c
index 411c1af92c62..0e5a4493ba4f 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -301,13 +301,12 @@ static void esd_usb2_rx_event(struct esd_usb2_net=
_priv *priv,
 			cf->data[7] =3D rxerr;
 		}
=20
-		netif_rx(skb);
-
 		priv->bec.txerr =3D txerr;
 		priv->bec.rxerr =3D rxerr;
=20
 		stats->rx_packets++;
 		stats->rx_bytes +=3D cf->can_dlc;
+		netif_rx(skb);
 	}
 }
=20
@@ -347,10 +346,9 @@ static void esd_usb2_rx_can_msg(struct esd_usb2_ne=
t_priv *priv,
 				cf->data[i] =3D msg->msg.rx.data[i];
 		}
=20
-		netif_rx(skb);
-
 		stats->rx_packets++;
 		stats->rx_bytes +=3D cf->can_dlc;
+		netif_rx(skb);
 	}
=20
 	return;
--=20
2.1.4

