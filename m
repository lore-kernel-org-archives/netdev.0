From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 1/3 2.5] e100 - Use pci_device_name for syslog messages till
 registering netdevice
Date: Fri, 17 Sep 2004 02:53:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170206350.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e100.c linux-2.5/drivers/net/e100.c.new
--- linux-2.5/drivers/net/e100.c	2004-09-09 14:51:31.000000000 -0700
+++ linux-2.5/drivers/net/e100.c.new	2004-09-09 14:51:32.000000000 -0700
@@ -2173,6 +2173,7 @@ static int __devinit e100_probe(struct p
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e100_netpoll;
 #endif
+	strcpy(netdev->name, pci_name(pdev));
 
 	nic = netdev_priv(netdev);
 	nic->netdev = netdev;
@@ -2256,6 +2257,7 @@ static int __devinit e100_probe(struct p
 
 	pci_enable_wake(pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
 
+	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
 		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
 		goto err_out_free;
