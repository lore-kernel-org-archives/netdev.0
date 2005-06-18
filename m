From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: Poll for link changes
Date: Sat, 18 Jun 2005 16:27:19 +0200
Message-ID: <42B42F47.2090105@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080805060801050701020906"
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080805060801050701020906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

Several users reported that the link speed detection is unreliable with 
nForce 3 nics. The result is either a completely dead network 
connection, or the connection dies after a few minutes.
The attached patch enables a timer that polls the PHY for link speed 
changes. The code already exists for nForce 1/2, the patch enables it 
for all nForce versions.

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

--------------080805060801050701020906
Content-Type: text/plain;
 name="patch-forcedeth-linktimer"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-linktimer"

--- 2.6/drivers/net/forcedeth.c	2005-06-18 16:21:47.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-06-18 15:03:55.000000000 +0200
@@ -82,7 +82,8 @@
  *	0.31: 14 Nov 2004: ethtool support for getting/setting link
  *	                   capabilities.
  *	0.32: 16 Apr 2005: RX_ERROR4 handling added.
- *	0.33: 16 Mai 2005: Support for MCP51 added.
+ *	0.33: 16 May 2005: Support for MCP51 added.
+ *	0.34: 18 Jun 2005: Add DEV_NEED_LINKTIMER to all nForce nics.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -94,7 +95,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.33"
+#define FORCEDETH_VERSION		"0.34"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -2218,70 +2219,70 @@
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_4,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce3 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_5,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce3 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_6,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* nForce3 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_7,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* CK804 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_8,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* CK804 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_9,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* MCP04 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_10,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* MCP04 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_11,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* MCP51 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_12,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{	/* MCP51 Ethernet Controller */
 		.vendor = PCI_VENDOR_ID_NVIDIA,
 		.device = PCI_DEVICE_ID_NVIDIA_NVENET_13,
 		.subvendor = PCI_ANY_ID,
 		.subdevice = PCI_ANY_ID,
-		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
 	},
 	{0,},
 };

--------------080805060801050701020906--
