From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Thu, 26 Feb 2009 18:12:32 -0700
Message-ID: <49A73E00.7050406@mlbassoc.com>
References: <49A49C06.90908@mlbassoc.com> <20090225131550.GA24996@xi.wantstofly.org> <49A5B877.8080403@mlbassoc.com> <20090226151107.GN17040@xi.wantstofly.org> <49A6B991.2090703@mlbassoc.com> <20090226155726.GO17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020704030202000006000605"
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:1533 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1759845AbZB0BMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 20:12:46 -0500
In-Reply-To: <20090226155726.GO17040@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020704030202000006000605
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Lennert Buytenhek wrote:
> On Thu, Feb 26, 2009 at 08:47:29AM -0700, Gary Thomas wrote:
> 
>>>>>> Is there support for this device anywhere?  In particular,
>>>>>> the M88E6095 switch.
>>>>> Not at the moment, but it should be easy enough to add.  If your
>>>>> board already runs on 2.6.28+, I can whip up some patches for you
>>>>> to try from the docs I have for that part.
>>>> That would be much appreciated, thanks.
>>> I noticed that the 6095/6095F are quite similar to the 6131 as far
>>> as the register set goes.  So something along these lines (hacky
>>> patch, breaks 6131, not for mainline) might just work to detect
>>> single 6095s (cascading DSA chips is something that needs more work,
>>> let's get the single-chip case working first).
>>>
>>> The other thing you'll need to do is create dsa platform devices
>>> for your switch chips, a la how it's done in arch/arm/mach-orion5x/
>>> or arch/arm/mach-kirkwood/ for example -- you need to pass in a struct
>>> device * for your network device, a struct device * for your mii bus,
>>> the switch MII address on the MII bus, and names of the individual
>>> ports (where you'll specify "cpu" for the port on the switch chip that
>>> the CPU is connected to).
>>>
>>> Let me know if this works.
>> Thanks, I'll give it a try.  It will take a little effort
>> to get setup as I have to work within the open firmware
>> structure (that's how all the various components are
>> specified).
> 
> Right, we don't have OF bindings yet.  I guess this would make sense
> to do generically at some point, since there are quite a few PPC
> platforms with DSA switch chips.

Here's what I tried - (patch attached) - a trulyhorrible hack,
but I've not figured out how to get the correct device pointers
from the OF world yet.  The boot log shows that it's trying, but
I don't see the DSA layer (M88E690x driver) doing the MII indirection
that's needed for this device.

I'm probably not starting it up correctly, but I think I followed
the examples you cited.  Any ideas?

Thanks

=============== boot log ===============================
Set gianfar_mdio = cf82fc08, mii_bus = cf9db400
gfar_mdio_read(cf9db400, 32, 2) = 0
gfar_mdio_read(cf9db400, 32, 3) = 0
gfar_mdio_read(cf9db400, 31, 2) = ffff
gfar_mdio_read(cf9db400, 31, 3) = ffff
gfar_mdio_read(cf9db400, 0, 2) = ffff
gfar_mdio_read(cf9db400, 0, 3) = ffff
gfar_mdio_read(cf9db400, 1, 2) = ffff
gfar_mdio_read(cf9db400, 1, 3) = ffff
gfar_mdio_read(cf9db400, 2, 2) = ffff
gfar_mdio_read(cf9db400, 2, 3) = ffff
gfar_mdio_read(cf9db400, 3, 2) = ffff
gfar_mdio_read(cf9db400, 3, 3) = ffff
gfar_mdio_read(cf9db400, 4, 2) = ffff
gfar_mdio_read(cf9db400, 4, 3) = ffff
gfar_mdio_read(cf9db400, 5, 2) = ffff
gfar_mdio_read(cf9db400, 5, 3) = ffff
gfar_mdio_read(cf9db400, 6, 2) = ffff
gfar_mdio_read(cf9db400, 6, 3) = ffff
gfar_mdio_read(cf9db400, 7, 2) = ffff
gfar_mdio_read(cf9db400, 7, 3) = ffff
gfar_mdio_read(cf9db400, 8, 2) = ffff
gfar_mdio_read(cf9db400, 8, 3) = ffff
gfar_mdio_read(cf9db400, 9, 2) = ffff
gfar_mdio_read(cf9db400, 9, 3) = ffff
gfar_mdio_read(cf9db400, 10, 2) = ffff
gfar_mdio_read(cf9db400, 10, 3) = ffff
gfar_mdio_read(cf9db400, 11, 2) = ffff
gfar_mdio_read(cf9db400, 11, 3) = ffff
gfar_mdio_read(cf9db400, 12, 2) = ffff
gfar_mdio_read(cf9db400, 12, 3) = ffff
gfar_mdio_read(cf9db400, 13, 2) = ffff
gfar_mdio_read(cf9db400, 13, 3) = ffff
gfar_mdio_read(cf9db400, 14, 2) = ffff
gfar_mdio_read(cf9db400, 14, 3) = ffff
gfar_mdio_read(cf9db400, 15, 2) = ffff
gfar_mdio_read(cf9db400, 15, 3) = ffff
gfar_mdio_read(cf9db400, 16, 2) = ffff
gfar_mdio_read(cf9db400, 16, 3) = ffff
gfar_mdio_read(cf9db400, 17, 2) = ffff
gfar_mdio_read(cf9db400, 17, 3) = ffff
gfar_mdio_read(cf9db400, 18, 2) = ffff
gfar_mdio_read(cf9db400, 18, 3) = ffff
gfar_mdio_read(cf9db400, 19, 2) = ffff
gfar_mdio_read(cf9db400, 19, 3) = ffff
gfar_mdio_read(cf9db400, 20, 2) = ffff
gfar_mdio_read(cf9db400, 20, 3) = ffff
gfar_mdio_read(cf9db400, 21, 2) = ffff
gfar_mdio_read(cf9db400, 21, 3) = ffff
gfar_mdio_read(cf9db400, 22, 2) = ffff
gfar_mdio_read(cf9db400, 22, 3) = ffff
gfar_mdio_read(cf9db400, 23, 2) = ffff
gfar_mdio_read(cf9db400, 23, 3) = ffff
gfar_mdio_read(cf9db400, 24, 2) = ffff
gfar_mdio_read(cf9db400, 24, 3) = ffff
gfar_mdio_read(cf9db400, 25, 2) = ffff
gfar_mdio_read(cf9db400, 25, 3) = ffff
gfar_mdio_read(cf9db400, 26, 2) = ffff
gfar_mdio_read(cf9db400, 26, 3) = ffff
gfar_mdio_read(cf9db400, 27, 2) = ffff
gfar_mdio_read(cf9db400, 27, 3) = ffff
gfar_mdio_read(cf9db400, 28, 2) = ffff
gfar_mdio_read(cf9db400, 28, 3) = ffff
gfar_mdio_read(cf9db400, 29, 2) = ffff
gfar_mdio_read(cf9db400, 29, 3) = ffff
gfar_mdio_read(cf9db400, 30, 2) = ffff
gfar_mdio_read(cf9db400, 30, 3) = ffff
gfar_mdio_read(cf9db400, 31, 2) = 0
gfar_mdio_read(cf9db400, 31, 3) = 0
Gianfar MII Bus: probed
Set gianfar_eth0 = cf82b008
eth0: Gianfar Ethernet Controller Version 1.2, 00:1d:11:81:00:00
eth0: Running with NAPI enabled
eth0: 256/256 RX/TX BD ring size
eth1: Gianfar Ethernet Controller Version 1.2, 00:1d:11:81:80:00
eth1: Running with NAPI enabled
eth1: 256/256 RX/TX BD ring size
   ... snipNET: Registered protocol family 17
Distributed Switch Architecture driver version 0.1
gfar_mdio_read(cf9db400, 16, 3) = ffff
mv88e6131_probe(cf9db400, 0) = 65535
eth0: could not detect attached switch
dsa: probe of dsa.0 failed with error -22
========================================================


-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------

--------------020704030202000006000605
Content-Type: text/plain;
 name="diffs"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diffs"

Index: drivers/net/gianfar_mii.c
===================================================================
--- drivers/net/gianfar_mii.c	(revision 4872)
+++ drivers/net/gianfar_mii.c	(working copy)
@@ -101,25 +101,36 @@
 /* Write value to the PHY at mii_id at register regnum,
  * on the bus, waiting until the write is done before returning.
  * All PHY configuration is done through the TSEC1 MIIM regs */
-int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+int _gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
 {
 	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
 
 	/* Write to the local MII regs */
 	return(gfar_local_mdio_write(regs, mii_id, regnum, value));
 }
+int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+{
+    int res = _gfar_mdio_write(bus, mii_id, regnum, value);
+    printk("%s(%p, %d, %d, %x) = %x\n", __FUNCTION__, bus, mii_id, regnum, value, res);
+    return res;
+}
 
 /* Read the bus for PHY at addr mii_id, register regnum, and
  * return the value.  Clears miimcom first.  All PHY
  * configuration has to be done through the TSEC1 MIIM regs */
-int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+int _gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
 	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
 
 	/* Read the local MII regs */
 	return(gfar_local_mdio_read(regs, mii_id, regnum));
 }
-
+int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+    int res = _gfar_mdio_read(bus, mii_id, regnum);
+    printk("%s(%p, %d, %d) = %x\n", __FUNCTION__, bus, mii_id, regnum, res);
+    return res;
+}
 /* Reset the MIIM registers, and wait for the bus to free */
 static int gfar_mdio_reset(struct mii_bus *bus)
 {
@@ -150,6 +161,9 @@
 	return 0;
 }
 
+// HACK
+struct device *gianfar_mdio;
+// HACK
 
 static int gfar_mdio_probe(struct device *dev)
 {
@@ -174,6 +188,11 @@
 	new_bus->reset = &gfar_mdio_reset,
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
 
+        // HACK
+        gianfar_mdio = dev;
+        printk("Set gianfar_mdio = %p, mii_bus = %p\n", dev, new_bus);
+        // HACK
+
 	pdata = (struct gianfar_mdio_data *)pdev->dev.platform_data;
 
 	if (NULL == pdata) {
Index: drivers/net/gianfar.c
===================================================================
--- drivers/net/gianfar.c	(revision 4872)
+++ drivers/net/gianfar.c	(working copy)
@@ -152,6 +152,30 @@
 	return (priv->vlan_enable || priv->rx_csum_enable);
 }
 
+// HACK
+#include <net/dsa.h>
+struct device *gianfar_eth0;
+extern struct device *gianfar_mdio;
+struct dsa_platform_data _switch_data = {
+    .port_names[0]  = "lan1.1",
+    .port_names[1]  = "lan1.2",
+    .port_names[2]  = "lan1.3",
+    .port_names[3]  = "lan1.4",
+    .port_names[4]  = "lan1.5",
+    .port_names[5]  = "lan1.6",
+    .port_names[6]  = "lan1.7",
+    .port_names[7]  = "lan1.8",
+    .port_names[10]  = "cpu",
+};
+
+struct platform_device _switch_device = {
+    .name           = "dsa",
+    .id             = 0,
+    .num_resources  = 0,
+};
+
+// HACK
+
 /* Set up the ethernet device structure, private data,
  * and anything else we need before we start */
 static int gfar_probe(struct platform_device *pdev)
@@ -164,6 +188,17 @@
 	int err = 0, irq;
 	DECLARE_MAC_BUF(mac);
 
+        // HACK
+        if (!gianfar_eth0) {
+            gianfar_eth0 = &pdev->dev;
+            printk("Set gianfar_eth0 = %p\n", &pdev->dev);
+            _switch_data.netdev = gianfar_eth0;
+            _switch_data.mii_bus = gianfar_mdio;
+            _switch_device.dev.platform_data = &_switch_data;
+            platform_device_register(&_switch_device);
+        }
+        // HACK
+
 	einfo = (struct gianfar_platform_data *) pdev->dev.platform_data;
 
 	if (NULL == einfo) {

--------------020704030202000006000605--
