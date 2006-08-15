From: akpm@osdl.org
Subject: [patch 1/2] e100 disable device on PCI error
Date: Mon, 14 Aug 2006 23:01:17 -0700
Message-ID: <200608150601.k7F61HgA012785@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, linas@austin.ibm.com,
	auke-jan.h.kok@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54937 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965214AbWHOGVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:21:16 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linas Vepstas <linas@austin.ibm.com>

A recent patch in -mm3 titled
"gregkh-pci-pci-don-t-enable-device-if-already-enabled.patch" causes
pci_enable_device() to be a no-op if the kernel thinks that the device is
already enabled.  This change breaks the PCI error recovery mechanism in
the e100 device driver, since, after PCI slot reset, the card is no longer
enabled.  This is a trivial fix for this problem.  Tested.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e100.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/e100.c~e100-disable-device-on-pci-error drivers/net/e100.c
--- a/drivers/net/e100.c~e100-disable-device-on-pci-error
+++ a/drivers/net/e100.c
@@ -2741,6 +2741,7 @@ static pci_ers_result_t e100_io_error_de
 	/* Detach; put netif into state similar to hotplug unplug. */
 	netif_poll_enable(netdev);
 	netif_device_detach(netdev);
+	pci_disable_device(pdev);
 
 	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
_
