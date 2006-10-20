From: akpm@osdl.org
Subject: [patch 8/8] e1000: Reset all functions after a PCI error
Date: Fri, 20 Oct 2006 14:42:14 -0700
Message-ID: <200610202142.k9KLgEcZ003738@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, linas@austin.ibm.com,
	auke-jan.h.kok@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28294 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992773AbWJTVsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:48:22 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linas Vepstas <linas@austin.ibm.com>

During the handling of the PCI error recovery sequence, the current e1000
driver erroneously blocks a device reset for any but the first PCI
function.  It shouldn't -- this is a cut-n-paste error from a different
driver (which tolerated only one hardware reset per hardware card).

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e1000/e1000_main.c |    4 ----
 1 files changed, 4 deletions(-)

diff -puN drivers/net/e1000/e1000_main.c~e1000-reset-all-functions-after-a-pci-error drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c~e1000-reset-all-functions-after-a-pci-error
+++ a/drivers/net/e1000/e1000_main.c
@@ -4914,10 +4914,6 @@ static pci_ers_result_t e1000_io_slot_re
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	/* Perform card reset only on one instance of the card */
-	if (PCI_FUNC (pdev->devfn) != 0)
-		return PCI_ERS_RESULT_RECOVERED;
-
 	e1000_reset(adapter);
 	E1000_WRITE_REG(&adapter->hw, WUS, ~0);
 
_
