From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] forcedeth: don't poll NV event 36
Date: Sun, 21 Dec 2008 20:44:06 +0100
Message-ID: <1229888646.3050.4.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Manfred Spraul <manfred@colorfullife.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:39486 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbYLUToM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 14:44:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Polling doesn't seem to be necessary on my hardware, at
least I haven't seen any bad effects testing it a while.
Remove the polling so the CPU doesn't have to wake up a
hundred times per second.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/forcedeth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- wireless-testing.orig/drivers/net/forcedeth.c	2008-12-21 13:01:14.000000000 +0100
+++ wireless-testing/drivers/net/forcedeth.c	2008-12-21 13:02:24.000000000 +0100
@@ -6141,7 +6141,7 @@ static struct pci_device_id pci_tbl[] = 
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_36),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
+		.driver_data = DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_37),


