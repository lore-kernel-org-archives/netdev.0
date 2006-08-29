From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 14/26] e100: fix error recovery
Date: Tue, 29 Aug 2006 09:44:46 -0700
Message-ID: <20060829164445.6872.50329.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:44298 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965088AbWH2Qgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:32 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A recent patch in -mm3 titled
"gregkh-pci-pci-don-t-enable-device-if-already-enabled.patch" causes
pci_enable_device() to be a no-op if the kernel thinks that the device is
already enabled.  This change breaks the PCI error recovery mechanism in
the e100 device driver, since, after PCI slot reset, the card is no longer
enabled.  This is a trivial fix for this problem.  Tested.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 458af6a..e12cc68 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2791,6 +2791,7 @@ static pci_ers_result_t e100_io_error_de
 	/* Detach; put netif into state similar to hotplug unplug. */
 	netif_poll_enable(netdev);
 	netif_device_detach(netdev);
+	pci_disable_device(pdev);
 
 	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;



---
Auke Kok <auke-jan.h.kok@intel.com>
