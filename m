From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [FYI] 2.6.x exp net drivers changelog
Date: Fri, 26 Dec 2003 22:23:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031226212335.GB197@elf.ucw.cz>
References: <3FDEA8F5.1020201@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osdl.org>, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FDEA8F5.1020201@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> <prasanna:in.ibm.com>:
>   o [netdrvr tlan] netpoll support
>   o [netdrvr smc-ultra] netpoll support

And here's netpoll for via-rhine... I hope it is allright? [I tested
it briefly, kgdb-over-this seemed to work.]

								Pavel

--- tmp/linux/drivers/net/via-rhine.c	2003-09-09 12:45:27.000000000 +0200
+++ linux/drivers/net/via-rhine.c	2003-12-25 22:34:37.000000000 +0100
@@ -615,6 +615,15 @@
 			break;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void via_rhine_poll(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	via_rhine_interrupt(dev->irq, (void *)dev, NULL);
+	enable_irq(dev->irq);
+}
+#endif
+
 static int __devinit via_rhine_init_one (struct pci_dev *pdev,
 					 const struct pci_device_id *ent)
 {
@@ -784,6 +793,9 @@
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->tx_timeout = via_rhine_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = via_rhine_poll;
+#endif
 	if (np->drv_flags & ReqTxAlign)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
-- 
When do you have a heart between your knees?
[Johanka's followup: and *two* hearts?]
