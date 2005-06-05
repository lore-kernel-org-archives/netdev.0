From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: add two new pci ids
Date: Sun, 05 Jun 2005 17:36:11 +0200
Message-ID: <42A31BEB.7030900@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060003070105090106070501"
Cc: AAbdulla@nvidia.com, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060003070105090106070501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

Ayaz wrote a patch that adds two new pci ids to the forcedeth driver. 
Could you add it to your tree? I'm not sure if it's worth to sneak it 
into 2.6.12, but it looks to be obviously correct (tm).

--
    Manfred

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>


--------------060003070105090106070501
Content-Type: text/plain;
 name="patch-forcedeth-mcp51"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-mcp51"

--- 2.6/drivers/net/forcedeth.c	2005-05-16 19:45:54.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-05-16 19:52:59.000000000 +0200
@@ -82,6 +82,7 @@
  *	0.31: 14 Nov 2004: ethtool support for getting/setting link
  *	                   capabilities.
  *	0.32: 16 Apr 2005: RX_ERROR4 handling added.
+ *	0.33: 16 Mai 2005: Support for MCP51 added.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -93,7 +94,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.32"
+#define FORCEDETH_VERSION		"0.33"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -1998,7 +1999,9 @@
 	/* handle different descriptor versions */
 	if (pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_1 ||
 		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_2 ||
-		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3)
+		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3 ||    
+		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
+		pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_13)
 		np->desc_ver = DESC_VER_1;
 	else
 		np->desc_ver = DESC_VER_2;
@@ -2256,6 +2259,20 @@
 		.subdevice = PCI_ANY_ID,
 		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
 	},
+	{	/* MCP51 Ethernet Controller */
+		.vendor = PCI_VENDOR_ID_NVIDIA,
+		.device = PCI_DEVICE_ID_NVIDIA_NVENET_12,
+		.subvendor = PCI_ANY_ID,
+		.subdevice = PCI_ANY_ID,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+	},
+	{	/* MCP51 Ethernet Controller */
+		.vendor = PCI_VENDOR_ID_NVIDIA,
+		.device = PCI_DEVICE_ID_NVIDIA_NVENET_13,
+		.subvendor = PCI_ANY_ID,
+		.subdevice = PCI_ANY_ID,
+		.driver_data = DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
+	},
 	{0,},
 };
 

--------------060003070105090106070501--
