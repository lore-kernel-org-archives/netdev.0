From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] natsemi: long cable, short cable
Date: Tue, 8 Feb 2005 15:18:49 +0100
Message-ID: <20050208141849.GC23971@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The current version of the natsemi driver comes with a workaround
for a hardware problem that causes link failures on short cables.
Unfortunately, this workaround causes massive link failures on _long_
cables (270-300ft). This patch adds a module parameter to disable
the workaround if required.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.10/drivers/net/natsemi.c
===================================================================
--- linux-2.6.10.orig/drivers/net/natsemi.c
+++ linux-2.6.10/drivers/net/natsemi.c
@@ -186,6 +186,7 @@ static int debug = -1;
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static int max_interrupt_work = 20;
 static int mtu;
+static int no_cable_magic = 0;
 
 /* Maximum number of multicast addresses to filter (vs. rx-all-multicast).
    This chip uses a 512 element hash table based on the Ethernet CRC.  */
@@ -257,6 +258,7 @@ module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
+module_param(no_cable_magic, int, 0);
 MODULE_PARM_DESC(max_interrupt_work, 
 	"DP8381x maximum events handled per interrupt");
 MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");
@@ -266,6 +268,9 @@ MODULE_PARM_DESC(rx_copybreak, 
 MODULE_PARM_DESC(options, 
 	"DP8381x: Bits 0-3: media type, bit 17: full duplex");
 MODULE_PARM_DESC(full_duplex, "DP8381x full duplex setting(s) (1)");
+MODULE_PARM_DESC(no_cable_magic,
+	"DP8381x: set no_cable_magic=1 to disable magic workaround for short cables "
+	"(may help with long cables:-)");
 
 /*
 				Theory of Operation
@@ -1578,6 +1583,9 @@ static void do_cable_magic(struct net_de
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = ns_ioaddr(dev);
 
+	if (no_cable_magic)
+		return;
+
 	if (dev->if_port != PORT_TP)
 		return;
 
@@ -1623,6 +1631,9 @@ static void undo_cable_magic(struct net_
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
 
+	if (no_cable_magic)
+		return;
+
 	if (dev->if_port != PORT_TP)
 		return;
 

-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
