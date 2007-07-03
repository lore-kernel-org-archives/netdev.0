From: Marian Balakowicz <m8@semihalf.com>
Subject: [PATCH] PCI: quirk_e100_interrupt() called too early
Date: Tue, 03 Jul 2007 11:03:18 +0200
Message-ID: <468A10D6.2020900@semihalf.com>
References: <4683A80F.5020605@semihalf.com> <4683DB44.9070704@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: bjorn.helgaas@hp.com, linux-pci@atrey.karlin.mff.cuni.cz,
	len.brown@intel.com, NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.semihalf.com ([83.12.36.68]:36191 "EHLO mail.semihalf.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264AbXGCJbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 05:31:13 -0400
In-Reply-To: <4683DB44.9070704@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---

 drivers/pci/quirks.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 01d8f8a..7194074 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -1475,7 +1475,7 @@ static void __devinit quirk_e100_interru

 	iounmap(csr);
 }
-DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, quirk_e100_interrupt);
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, quirk_e100_interrupt);

 static void __devinit fixup_rev1_53c810(struct pci_dev* dev)
 {



