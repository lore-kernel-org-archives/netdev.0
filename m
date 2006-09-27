From: Manish Lachwani <mlachwani@mvista.com>
Subject: [PATCH] Add NETPOLL Support to SB1250 driver
Date: Tue, 26 Sep 2006 18:59:18 -0700
Message-ID: <20060927015918.GA21824@prometheus.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Cc: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:10493 "EHLO
	prometheus.mvista.com") by vger.kernel.org with ESMTP
	id S932256AbWI0B71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 21:59:27 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello!

Attached patch adds NETPOLL support for the Sibyte Network driver.

Thanks,
Manish Lachwani

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mips_sb1250_netpoll.patch"

Source: MontaVista Software, Inc. | Manish Lachwani <mlachwani@mvista.com>

NETPOLL support for Sibyte MAC

 drivers/net/sb1250-mac.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+)

Index: linux-2.6.18/drivers/net/sb1250-mac.c
===================================================================
--- linux-2.6.18.orig/drivers/net/sb1250-mac.c
+++ linux-2.6.18/drivers/net/sb1250-mac.c
@@ -1128,6 +1128,17 @@ static void sbdma_fillring(sbmacdma_t *d
 	}
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void sbmac_netpoll(struct net_device *netdev)
+{
+	struct sbmac_softc *sc = netdev_priv(netdev);
+	int irq = sc->sbm_dev->irq;
+
+	disable_irq(irq);
+	sbmac_intr(irq, netdev, NULL);
+	enable_irq(irq);
+}
+#endif
 
 /**********************************************************************
  *  SBDMA_RX_PROCESS(sc,d)
@@ -2402,6 +2413,9 @@ static int sbmac_init(struct net_device 
 	dev->watchdog_timeo     = TX_TIMEOUT;
 
 	dev->change_mtu         = sb1250_change_mtu;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = sbmac_netpoll;
+#endif
 
 	/* This is needed for PASS2 for Rx H/W checksum feature */
 	sbmac_set_iphdr_offset(sc);

--+HP7ph2BbKc20aGI--
