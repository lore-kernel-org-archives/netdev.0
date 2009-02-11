From: akpm@linux-foundation.org
Subject: [patch 2/2] forcedeth: fix MAC address detection on network card (regression in 2.6.23)
Date: Wed, 11 Feb 2009 13:27:36 -0800
Message-ID: <200902112127.n1BLRa7B032045@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	michael.pyne@kdemail.net, AAbdulla@nvidia.com, aabdulla@nvidia.com,
	jeff@garzik.org, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38373 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758781AbZBKV2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 16:28:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: <stable@kernel.org>

On Wed, 21 Nov 2007 15:34:52 -0800
"Ayaz Abdulla" <AAbdulla@nvidia.com> wrote:

> The solution is to get the OEM to update their BIOS (instead of
> integrating this patch) since the MCP61 specs indicate that the MAC
> Address should be in correct order from BIOS.
> 
> By changing the feature DEV_HAS_CORRECT_MACADDR to all MCP61 boards, it
> could cause it to break on other OEM systems who have implemented it
> correctly.
> 

On Tue, 05 Feb 2008 13:20:59 -0500 Jeff Garzik <jeff@garzik.org> wrote:
> NAK - this fixes one set of users, and breaks a working set of users.
> 
> Need to add DMI check for the specific motherboard (dmi_check_system), 
> and flip flag according to success/failure of that check.

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/forcedeth.c~forcedeth-fix-mac-address-detection-on-network-card-regression-in-2623 drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-fix-mac-address-detection-on-network-card-regression-in-2623
+++ a/drivers/net/forcedeth.c
@@ -6180,7 +6180,7 @@ static struct pci_device_id pci_tbl[] = 
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_16),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_17),
_
