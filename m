From: <gregkh@suse.de>
Subject: patch pci-quirk_e100_interrupt-called-too-early.patch added to gregkh-2.6 tree
Date: Tue, 17 Jul 2007 10:21:08 -0700
Message-ID: <20070717172109.0DA7614540D0@imap.suse.de>
References: <468A10D6.2020900@semihalf.com>
To: m8@semihalf.com, auke-jan.h.kok@intel.com, gregkh@suse.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:51373 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752718AbXGQRVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 13:21:13 -0400
In-Reply-To: <468A10D6.2020900@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a note to let you know that I've just added the patch titled

     Subject: [PATCH] PCI: quirk_e100_interrupt() called too early

to my gregkh-2.6 tree.  Its filename is

     pci-quirk_e100_interrupt-called-too-early.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From owner-linux-pci@atrey.karlin.mff.cuni.cz Tue Jul  3 02:03:55 2007
From: Marian Balakowicz <m8@semihalf.com>
Date: Tue, 03 Jul 2007 11:03:18 +0200
Subject: [PATCH] PCI: quirk_e100_interrupt() called too early
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Cc: bjorn.helgaas@hp.com, linux-pci@atrey.karlin.mff.cuni.cz, len.brown@intel.com, NetDev <netdev@vger.kernel.org>
Message-ID: <468A10D6.2020900@semihalf.com>


quirk_e100_interrupts() is called after PCI controller is initialized
and before PCI bus enumeration is performed. On some powerpc platforms
which modify PCI controller configuration and set different MEM and IO
windows than those set by firmware quirk_e100_interrupt() is causing
kernel panic as it tries to read from device BAR0 offets which at this
time points to a invalid PCI window (set by firmware).

This patch delays the quirk_100_interrupt() to pci_fixup_final phase,
which happens after bus enumeration and before PCI enable and
device driver initialization.

Signed-off-by: Marian Balakowicz <m8@semihalf.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/pci/quirks.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -1485,7 +1485,7 @@ static void __devinit quirk_e100_interru
 
 	iounmap(csr);
 }
-DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, quirk_e100_interrupt);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, quirk_e100_interrupt);
 
 static void __devinit fixup_rev1_53c810(struct pci_dev* dev)
 {


Patches currently in gregkh-2.6 which might be from m8@semihalf.com are

pci/pci-quirk_e100_interrupt-called-too-early.patch
