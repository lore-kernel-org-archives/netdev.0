From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] Subjec: sky2, skge: correct PCI id for DGE-560T
Date: Wed, 17 May 2006 14:37:04 -0700
Message-ID: <20060517213802.140189000@localhost.localdomain>
References: <20060517213702.322762000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63928 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751155AbWEQVlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 17:41:49 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=dlink-560t.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Dlink DGE-560T uses Yukon2 chipset so it needs sky2 driver; and
the DGE-530T uses Yukon1 so it uses skge driver.

Bug: http://bugzilla.kernel.org/show_bug.cgi?id=6544

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/skge.c	2006-04-27 11:12:39.000000000 -0700
+++ sky2/drivers/net/skge.c	2006-05-16 10:35:27.000000000 -0700
@@ -78,8 +78,7 @@
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_GE) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T), },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },
-	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	/* DGE-530T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) }, /* Belkin */
 	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD) },
--- sky2.orig/drivers/net/sky2.c	2006-05-16 10:34:22.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-05-16 10:35:49.000000000 -0700
@@ -105,6 +105,7 @@
 static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4340) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4341) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4342) },

--

