From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: Addition of new device id (resend without pci_ids.h)
Date: Wed, 03 Jun 2009 12:06:04 -0400
Message-ID: <4A269F6C.7030300@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050509060803080407010505"
To: Manfred Spraul <manfred@colorfullife.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:3760 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbZFCVi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:38:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050509060803080407010505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Add support for new ethernet device in the MCP89 chipset.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------050509060803080407010505
Content-Type: text/plain;
 name="patch-forcedeth-mcp89-device"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-mcp89-device"

--- old/drivers/net/forcedeth.c	2009-06-02 14:53:45.000000000 -0400
+++ new/drivers/net/forcedeth.c	2009-06-03 11:59:53.000000000 -0400
@@ -70,6 +70,11 @@
 #define dprintk(x...)		do { } while (0)
 #endif
 
+/*
+ * Hardware device ids (no longer updating pci_ids.h)
+ */
+#define PCI_DEVICE_ID_NVIDIA_NVENET_40  0x0D7D
+
 #define TX_WORK_PER_LOOP  64
 #define RX_WORK_PER_LOOP  64
 
@@ -6149,7 +6154,8 @@
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
-	pci_write_config_dword(pdev, NV_MSI_PRIV_OFFSET, NV_MSI_PRIV_VALUE);
+	if (np->device_id != PCI_DEVICE_ID_NVIDIA_NVENET_40)
+		pci_write_config_dword(pdev, NV_MSI_PRIV_OFFSET, NV_MSI_PRIV_VALUE);
 
 	/* restore phy state, including autoneg */
 	phy_init(dev);
@@ -6353,6 +6359,10 @@
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
 		.driver_data = DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
+	{	/* MCP89 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_40),
+		.driver_data = DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+	},
 	{0,},
 };
 

--------------050509060803080407010505--
