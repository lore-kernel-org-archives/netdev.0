From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: [PATCH] forcedeth: netpoll support
Date: Tue, 29 Mar 2005 11:33:38 +0200
Message-ID: <424920F2.4040207@stud.feec.vutbr.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080409090500010805040408"
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: manfred@colorfullife.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080409090500010805040408
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit

Hello,
This adds support for netpoll to forcedeth. It works for Julien Wajsberg 
(see LKML thread "How's the nforce4 support in Linux?").

Signed-off-by: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>


--------------080409090500010805040408
Content-Type: text/x-patch;
 name="forcedeth-netpoll.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="forcedeth-netpoll.patch"

--- linux-2.6.12-rc1/drivers/net/forcedeth.c.orig	2005-03-26 15:00:12.000000000 +0100
+++ linux-2.6.12-rc1/drivers/net/forcedeth.c	2005-03-26 15:08:56.000000000 +0100
@@ -1480,6 +1480,13 @@ static void nv_do_nic_poll(unsigned long
 	enable_irq(dev->irq);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void nv_poll_controller(struct net_device *dev)
+{
+	nv_do_nic_poll((unsigned long) dev);
+}
+#endif
+
 static void nv_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct fe_priv *np = get_nvpriv(dev);
@@ -1962,6 +1969,9 @@ static int __devinit nv_probe(struct pci
 	dev->get_stats = nv_get_stats;
 	dev->change_mtu = nv_change_mtu;
 	dev->set_multicast_list = nv_set_multicast;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = nv_poll_controller;
+#endif
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->tx_timeout = nv_tx_timeout;
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;

--------------080409090500010805040408--
