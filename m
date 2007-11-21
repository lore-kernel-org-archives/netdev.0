From: akpm@linux-foundation.org
Subject: [patch 2/8] forcedeth: fix MAC address detection on network card (regression in 2.6.23)
Date: Wed, 21 Nov 2007 15:02:53 -0800
Message-ID: <200711212302.lALN2sF8013655@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	michael.pyne@kdemail.net, aabdulla@nvidia.com, stable@kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50450 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753863AbXKUXDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:03:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Pyne <michael.pyne@kdemail.net>

Partially revert a change to mac address detection introduced to the forcedeth
driver.  The change was intended to correct mac address detection for newer
nVidia chipsets where the mac address was stored in reverse order.  One of
those chipsets appears to still have the mac address in reverse order (or at
least, it does on my system).

The change that broke mac address detection for my card was commit
ef756b3e56c68a4d76d9d7b9a73fa8f4f739180f "forcedeth: mac address correct"

My network card is an nVidia built-in Ethernet card, output from lspci as
follows (with text and numeric ids):
$ lspci | grep Ethernet
00:07.0 Bridge: nVidia Corporation MCP61 Ethernet (rev a2)
$ lspci -n | grep 07.0
00:07.0 0680: 10de:03ef (rev a2)

The vendor id is, of course, nVidia.  The device id corresponds to the
NVIDIA_NVENET_19 entry.

The included patch fixes the MAC address detection on my system.
Interestingly, the MAC address appears to be in the range reserved for my
motherboard manufacturer (Gigabyte) and not nVidia.

Signed-off-by: Michael J. Pyne <michael.pyne@kdemail.net>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/forcedeth.c~forcedeth-fix-mac-address-detection-on-network-card-regression-in-2623 drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-fix-mac-address-detection-on-network-card-regression-in-2623
+++ a/drivers/net/forcedeth.c
@@ -5555,7 +5555,7 @@ static struct pci_device_id pci_tbl[] = 
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_19),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
_
