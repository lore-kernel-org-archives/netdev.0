From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/3]: sk98lin: neuter device to only SysKonnect boards
Date: Wed, 12 Sep 2007 13:30:43 +0200
Message-ID: <20070912133043.1a15aabe@oldman>
References: <6278d2220707271227g51cb147ch2f6dbc05c73f618d@mail.gmail.com>
 <20070911132423.62347d5c@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57967 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765106AbXILLbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:31:00 -0400
In-Reply-To: <20070911132423.62347d5c@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The skge driver works better for all boards except older SysKonnect
boards.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 drivers/net/sk98lin/skge.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
index bf21862..7dc9c9e 100644
--- a/drivers/net/sk98lin/skge.c
+++ b/drivers/net/sk98lin/skge.c
@@ -5168,10 +5168,17 @@ err_out:
 #endif
 
 static struct pci_device_id skge_pci_tbl[] = {
+#ifdef SK98LIN_ALL_DEVICES
 	{ PCI_VENDOR_ID_3COM, 0x1700, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_3COM, 0x80eb, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+#endif
+#ifdef GENESIS
+	/* Generic SysKonnect SK-98xx Gigabit Ethernet Server Adapter */	
 	{ PCI_VENDOR_ID_SYSKONNECT, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+#endif
+	/* Generic SysKonnect SK-98xx V2.0 Gigabit Ethernet Adapter */	
 	{ PCI_VENDOR_ID_SYSKONNECT, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+#ifdef SK98LIN_ALL_DEVICES
 /* DLink card does not have valid VPD so this driver gags
  *	{ PCI_VENDOR_ID_DLINK, 0x4c00, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
  */
@@ -5180,6 +5187,7 @@ static struct pci_device_id skge_pci_tbl[] = {
 	{ PCI_VENDOR_ID_CNET, 0x434e, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_LINKSYS, 0x1032, PCI_ANY_ID, 0x0015, },
 	{ PCI_VENDOR_ID_LINKSYS, 0x1064, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+#endif
 	{ 0 }
 };
 
-- 
1.5.2.5

