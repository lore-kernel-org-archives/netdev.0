From: Michael Pyne <michael.pyne@kdemail.net>
Subject: [PATCH] forcedeth: Fix MAC address detection on network card (regression in 2.6.23)
Date: Thu, 11 Oct 2007 22:42:50 -0400
Message-ID: <200710112242.50167.michael.pyne@kdemail.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:43857 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045AbXJLCpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 22:45:14 -0400
Received: from postalmail-a3.g.dreamhost.com (sd-green-bigip-81.dreamhost.com [208.97.132.81])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 2FC12195E81
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 19:44:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Partially revert a change to mac address detection introduced to the forcedeth 
driver.  The change was intended to correct mac address detection for newer 
nVidia chipsets where the mac address was stored in reverse order.  One of 
those chipsets appears to still have the mac address in reverse order (or at 
least, it does on my system).

Signed-off-by: Michael J. Pyne <michael.pyne@kdemail.net>
---
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

If you need any further information about my hardware configuration just let 
me know.

Regards,
 - Michael Pyne

--- a/drivers/net/forcedeth.c       2007-10-11 22:01:26 -0400
+++ b/drivers/net/forcedeth-new.c   2007-10-11 22:06:52 -0400
@@ -5513,7 +5513,7 @@ static struct pci_device_id pci_tbl[] = 
 	},
 	{	/* MCP61 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_19),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|
DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|
DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|
DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|
DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
