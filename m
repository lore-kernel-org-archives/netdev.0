From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH 2/5] orinoco: report more relevant data on startup
Date: Mon, 01 May 2006 02:13:26 -0400
Message-ID: <20060501061326.13342.11197.stgit@dv.roinet.com>
References: <20060501061324.13342.58195.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:57312 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1751276AbWEAGN2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 02:13:28 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FaRex-0007G1-CE
	for netdev@vger.kernel.org; Mon, 01 May 2006 02:13:27 -0400
To: netdev@vger.kernel.org, linville@tuxdriver.com
In-Reply-To: <20060501061324.13342.58195.stgit@dv.roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

Report only the first I/O window and IRQ, and also add the driver name. 
The second I/O window, Vpp and configuration index are not interesting
to most users.  They can be found by PCMCIA debug tools if needed.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/orinoco_cs.c  |   17 ++++-------------
 drivers/net/wireless/spectrum_cs.c |   17 ++++-------------
 2 files changed, 8 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index ee05ec6..1c19c76 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -343,19 +343,10 @@ orinoco_cs_config(struct pcmcia_device *
                                     net_device has been registered */
 
 	/* Finally, report what we've done */
-	printk(KERN_DEBUG "%s: index 0x%02x: ",
-	       dev->name, link->conf.ConfigIndex);
-	if (link->conf.Vpp)
-		printk(", Vpp %d.%d", link->conf.Vpp / 10,
-		       link->conf.Vpp % 10);
-	printk(", irq %d", link->irq.AssignedIRQ);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
-	printk("\n");
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s, irq %d, io "
+	       "0x%04x-0x%04x\n", dev->name, dev->class_dev.dev->bus_id,
+	       link->irq.AssignedIRQ, link->io.BasePort1,
+	       link->io.BasePort1 + link->io.NumPorts1 - 1);
 
 	return 0;
 
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index 0921162..e9172ee 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -822,19 +822,10 @@ spectrum_cs_config(struct pcmcia_device 
                                     net_device has been registered */
 
 	/* Finally, report what we've done */
-	printk(KERN_DEBUG "%s: index 0x%02x: ",
-	       dev->name, link->conf.ConfigIndex);
-	if (link->conf.Vpp)
-		printk(", Vpp %d.%d", link->conf.Vpp / 10,
-		       link->conf.Vpp % 10);
-	printk(", irq %d", link->irq.AssignedIRQ);
-	if (link->io.NumPorts1)
-		printk(", io 0x%04x-0x%04x", link->io.BasePort1,
-		       link->io.BasePort1 + link->io.NumPorts1 - 1);
-	if (link->io.NumPorts2)
-		printk(" & 0x%04x-0x%04x", link->io.BasePort2,
-		       link->io.BasePort2 + link->io.NumPorts2 - 1);
-	printk("\n");
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s, irq %d, io "
+	       "0x%04x-0x%04x\n", dev->name, dev->class_dev.dev->bus_id,
+	       link->irq.AssignedIRQ, link->io.BasePort1,
+	       link->io.BasePort1 + link->io.NumPorts1 - 1);
 
 	return 0;
 

