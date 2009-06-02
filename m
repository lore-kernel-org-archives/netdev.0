From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/2] forcedeth: Addition of new device id
Date: Tue, 02 Jun 2009 15:18:50 -0400
Message-ID: <4A257B1A.8080205@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010508010303050408010305"
To: Manfred Spraul <manfred@colorfullife.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:1357 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbZFCAvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 20:51:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010508010303050408010305
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds support for new ethernet device in the MCP89 chipset.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------010508010303050408010305
Content-Type: text/plain;
 name="patch-forcedeth-mcp89-device"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-mcp89-device"

--- old/drivers/net/forcedeth.c	2009-06-02 14:53:45.000000000 -0400
+++ new/drivers/net/forcedeth.c	2009-06-02 14:53:49.000000000 -0400
@@ -6149,7 +6149,8 @@
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
-	pci_write_config_dword(pdev, NV_MSI_PRIV_OFFSET, NV_MSI_PRIV_VALUE);
+	if (np->device_id != PCI_DEVICE_ID_NVIDIA_NVENET_40)
+		pci_write_config_dword(pdev, NV_MSI_PRIV_OFFSET, NV_MSI_PRIV_VALUE);
 
 	/* restore phy state, including autoneg */
 	phy_init(dev);
@@ -6353,6 +6354,10 @@
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
 		.driver_data = DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
+	{	/* MCP89 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_40),
+		.driver_data = DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+	},
 	{0,},
 };
 

--------------010508010303050408010305--
