From: "Mosler, Martin" <mmo@zuehlke.com>
Subject: [PATCH] net/can/mscan: Enable interrupts when all TX buffers are
 occupied to get notified when they are available again
Date: Mon, 28 Nov 2011 13:25:30 +0000
Message-ID: <C3745E3C7FD07D429C54EB3D7606A5A7677E7C@ZRHEX021.ads.zuehlke.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"socketcan@hartkopp.net" <socketcan@hartkopp.net>,
	"lucas.demarchi@profusion.mobi" <lucas.demarchi@profusion.mobi>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: de-CH
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When all TX buffers of the mscan are occupied the network layer is told to stop sending further packets. However the TX interrupts are not enabled and therefore the driver has no chance to tell the network layer when it is ready to accept further packets.

Signed-off-by: Martin Mosler <mmo@zuehlke.com>

--- linux-2.6/drivers/net/can/mscan/mscan.c.orig    2011-11-28 13:54:29.547850661 +0100
+++ linux-2.6/drivers/net/can/mscan/mscan.c 2011-11-28 13:55:52.427849601 +0100
@@ -214,6 +214,7 @@ static netdev_tx_t mscan_start_xmit(stru
    case 0:
        netif_stop_queue(dev);
        dev_err(dev->dev.parent, "Tx Ring full when queue awake!\n");
+       out_8(&regs->cantier, priv->tx_active);
        return NETDEV_TX_BUSY;
    case 1:
        /*  
