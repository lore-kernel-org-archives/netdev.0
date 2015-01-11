From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v4 2/4] can: kvaser_usb: Update error counters before exiting
 on OOM
Date: Sun, 11 Jan 2015 15:15:19 -0500
Message-ID: <20150111201519.GC8855@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150111200544.GA8855@linux>
 <20150111201116.GB8855@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150111201116.GB8855@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

Let the error counters be more accurate in case of Out of
Memory conditions.

Suggested-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/kvaser_usb.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index c32cd61..0eb870b 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -792,6 +792,9 @@ static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
 	}
 
 	if (msg->u.rx_can.flag & MSG_FLAG_OVERRUN) {
+		stats->rx_over_errors++;
+		stats->rx_errors++;
+
 		skb = alloc_can_err_skb(priv->netdev, &cf);
 		if (!skb) {
 			stats->rx_dropped++;
@@ -801,9 +804,6 @@ static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
 		cf->can_id |= CAN_ERR_CRTL;
 		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
 
-		stats->rx_over_errors++;
-		stats->rx_errors++;
-
 		stats->rx_packets++;
 		stats->rx_bytes += cf->can_dlc;
 		netif_rx(skb);
-- 
1.9.1

