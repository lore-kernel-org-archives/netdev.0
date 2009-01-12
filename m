From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: Fix NAPI interface in IXP4xx HSS driver.
Date: Mon, 12 Jan 2009 02:04:12 +0100
Message-ID: <m3r63949o3.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45566 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751744AbZALBEP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 20:04:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WAN: Fix NAPI interface in IXP4xx HSS driver.
   =20
Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.=
c
index 2dc2416..0dbd85b 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -622,7 +622,7 @@ static void hss_hdlc_rx_irq(void *pdev)
 	printk(KERN_DEBUG "%s: hss_hdlc_rx_irq\n", dev->name);
 #endif
 	qmgr_disable_irq(queue_ids[port->id].rx);
-	netif_rx_schedule(dev, &port->napi);
+	netif_rx_schedule(&port->napi);
 }
=20
 static int hss_hdlc_poll(struct napi_struct *napi, int budget)
@@ -651,7 +651,7 @@ static int hss_hdlc_poll(struct napi_struct *napi, =
int budget)
 			printk(KERN_DEBUG "%s: hss_hdlc_poll"
 			       " netif_rx_complete\n", dev->name);
 #endif
-			netif_rx_complete(dev, napi);
+			netif_rx_complete(napi);
 			qmgr_enable_irq(rxq);
 			if (!qmgr_stat_empty(rxq) &&
 			    netif_rx_reschedule(napi)) {
@@ -1069,7 +1069,7 @@ static int hss_hdlc_open(struct net_device *dev)
 	hss_start_hdlc(port);
=20
 	/* we may already have RX data, enables IRQ */
-	netif_rx_schedule(dev, &port->napi);
+	netif_rx_schedule(&port->napi);
 	return 0;
=20
 err_unlock:

--=20
Krzysztof Halasa
