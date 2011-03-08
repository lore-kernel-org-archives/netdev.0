From: roel <roel.kluin@gmail.com>
Subject: [PATCH] can: wrong index used in inner loop
Date: Tue, 08 Mar 2011 20:52:55 +0100
Message-ID: <4D768917.9040605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Index i was already used in the outer loop.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/can/usb/esd_usb2.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index 05a5275..dc53c83 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -659,7 +659,7 @@ failed:
 static void unlink_all_urbs(struct esd_usb2 *dev)
 {
 	struct esd_usb2_net_priv *priv;
-	int i;
+	int i, j;
 
 	usb_kill_anchored_urbs(&dev->rx_submitted);
 	for (i = 0; i < dev->net_count; i++) {
@@ -668,8 +668,8 @@ static void unlink_all_urbs(struct esd_usb2 *dev)
 			usb_kill_anchored_urbs(&priv->tx_submitted);
 			atomic_set(&priv->active_tx_jobs, 0);
 
-			for (i = 0; i < MAX_TX_URBS; i++)
-				priv->tx_contexts[i].echo_index = MAX_TX_URBS;
+			for (j = 0; j < MAX_TX_URBS; j++)
+				priv->tx_contexts[j].echo_index = MAX_TX_URBS;
 		}
 	}
 }
