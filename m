From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] ni5010: convert to net_device_ops
Date: Sun, 29 Mar 2009 06:26:13 +0400
Message-ID: <20090329022613.GA30897@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:22123 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346AbZC2C0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 22:26:24 -0400
Received: by fg-out-1718.google.com with SMTP id 16so149384fgg.17
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2009 19:26:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/ni5010.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 539e18a..b121e0f 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -189,6 +189,14 @@ static void __init trigger_irq(int ioaddr)
 		outb(MM_EN_XMT|MM_MUX, IE_MMODE); /* Start transmission */
 }
 
+static const struct net_device_ops ni5010_netdev_ops = {
+	.ndo_open		= ni5010_open,
+	.ndo_stop		= ni5010_close,
+	.ndo_start_xmit		= ni5010_send_packet,
+	.ndo_set_multicast_list	= ni5010_set_multicast_list,
+	.ndo_tx_timeout		= ni5010_timeout,
+};
+
 /*
  *      This is the real probe routine.  Linux has a history of friendly device
  *      probes on the ISA bus.  A good device probes avoids doing writes, and
@@ -328,13 +336,8 @@ static int __init ni5010_probe1(struct net_device *dev, int ioaddr)
         	outb(0, IE_RBUF);	/* set buffer byte 0 to 0 again */
 	}
         printk("-> bufsize rcv/xmt=%d/%d\n", bufsize_rcv, NI5010_BUFSIZE);
-	memset(netdev_priv(dev), 0, sizeof(struct ni5010_local));
 
-	dev->open		= ni5010_open;
-	dev->stop		= ni5010_close;
-	dev->hard_start_xmit	= ni5010_send_packet;
-	dev->set_multicast_list = ni5010_set_multicast_list;
-	dev->tx_timeout		= ni5010_timeout;
+	dev->netdev_ops		= &ni5010_netdev_ops;
 	dev->watchdog_timeo	= HZ/20;
 
 	dev->flags &= ~IFF_MULTICAST;	/* Multicast doesn't work */
