From: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Subject: RE: [patch 2/8] forcedeth: fix MAC address detection on network card (regression in 2.6.23)
Date: Wed, 21 Nov 2007 15:34:52 -0800
Message-ID: <F72FA20C31DD4F4C997B91C5B3690A091A9857@hqemmail07.nvidia.com>
References: <200711212302.lALN2sF8013655@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <michael.pyne@kdemail.net>,
	<stable@kernel.org>
To: <akpm@linux-foundation.org>, <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:7263 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbXKUXmD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:42:03 -0500
In-Reply-To: <200711212302.lALN2sF8013655@imap1.linux-foundation.org>
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The solution is to get the OEM to update their BIOS (instead of
integrating this patch) since the MCP61 specs indicate that the MAC
Address should be in correct order from BIOS.

By changing the feature DEV_HAS_CORRECT_MACADDR to all MCP61 boards, it
could cause it to break on other OEM systems who have implemented it
correctly.

Thanks,
Ayaz



-----Original Message-----
From: akpm@linux-foundation.org [mailto:akpm@linux-foundation.org] 
Sent: Wednesday, November 21, 2007 3:03 PM
To: jeff@garzik.org
Cc: netdev@vger.kernel.org; akpm@linux-foundation.org;
michael.pyne@kdemail.net; Ayaz Abdulla; stable@kernel.org
Subject: [patch 2/8] forcedeth: fix MAC address detection on network
card (regression in 2.6.23)


From: Michael Pyne <michael.pyne@kdemail.net>

Partially revert a change to mac address detection introduced to the
forcedeth
driver.  The change was intended to correct mac address detection for
newer
nVidia chipsets where the mac address was stored in reverse order.  One
of
those chipsets appears to still have the mac address in reverse order
(or at
least, it does on my system).

The change that broke mac address detection for my card was commit
ef756b3e56c68a4d76d9d7b9a73fa8f4f739180f "forcedeth: mac address
correct"

My network card is an nVidia built-in Ethernet card, output from lspci
as
follows (with text and numeric ids):
$ lspci | grep Ethernet
00:07.0 Bridge: nVidia Corporation MCP61 Ethernet (rev a2)
$ lspci -n | grep 07.0
00:07.0 0680: 10de:03ef (rev a2)

The vendor id is, of course, nVidia.  The device id corresponds to the
NVIDIA_NVENET_19 entry.

The included patch fixes the MAC address detection on my system.
Interestingly, the MAC address appears to be in the range reserved for
my
motherboard manufacturer (Gigabyte) and not nVidia.

Signed-off-by: Michael J. Pyne <michael.pyne@kdemail.net>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN
drivers/net/forcedeth.c~forcedeth-fix-mac-address-detection-on-network-c
ard-regression-in-2623 drivers/net/forcedeth.c
---
a/drivers/net/forcedeth.c~forcedeth-fix-mac-address-detection-on-network
-card-regression-in-2623
+++ a/drivers/net/forcedeth.c
@@ -5555,7 +5555,7 @@ static struct pci_device_id pci_tbl[] = 
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA,
PCI_DEVICE_ID_NVIDIA_NVENET_19),
-		.driver_data =
DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTR
L|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_E
XTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data =
DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTR
L|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_E
XTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA,
PCI_DEVICE_ID_NVIDIA_NVENET_20),
_
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
