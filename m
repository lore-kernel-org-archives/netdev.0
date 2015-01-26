From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v6 2/7] can: kvaser_usb: Send correct context to URB
 completion
Date: Mon, 26 Jan 2015 07:22:54 +0200
Message-ID: <20150126052254.GC3014@Darwish.PC>
References: <20141223154654.GB6460@vivalin-002>
 <20150126051755.GA3014@Darwish.PC>
 <20150126052039.GB3014@Darwish.PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150126052039.GB3014@Darwish.PC>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

Send expected argument to the URB completion hander: a CAN
netdevice instead of the network interface private context
`kvaser_usb_net_priv'.

This was discovered by having some garbage in the kernel
log in place of the netdevice names: can0 and can1.

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/kvaser_usb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 978a25e..f0c6207 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -587,7 +587,7 @@ static int kvaser_usb_simple_msg_async(struct kvaser_usb_net_priv *priv,
 			  usb_sndbulkpipe(dev->udev,
 					  dev->bulk_out->bEndpointAddress),
 			  buf, msg->len,
-			  kvaser_usb_simple_msg_callback, priv);
+			  kvaser_usb_simple_msg_callback, netdev);
 	usb_anchor_urb(urb, &priv->tx_submitted);
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
-- 
1.7.7.6

