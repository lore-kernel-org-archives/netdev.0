From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next] ioat/dca: Update DCA BIOS workarounds to use
 TAINT_FIRMWARE_WORKAROUND
Date: Fri, 22 Mar 2013 09:01:59 -0700
Message-ID: <20130322155407.14605.67885.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, gospo@redhat.com,
	david.woodhouse@intel.com, sassmann@redhat.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34656 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933488Ab3CVQED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 12:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is meant to be a follow-up for a patch originally submitted under
the title "ioat: Do not enable DCA if tag map is invalid".  It was brought to
my attention that the preferred approach for BIOS workarounds is to set the
taint flag for TAINT_FIRMWARE_WORKAROUND for systems that require BIOS
workarounds.

This change makes it so that the DCA workarounds for broken BIOSes will now
use WARN_TAINT_ONCE(1, TAINT_FIRMWARE_WORKAROUND, ...) instead of just
printing a message via dev_err.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

I am submitting this for net-next since that is the path that the original
patch that this is an update to had followed.  My apologies for not making
that clear in the original submission.

 drivers/dma/ioat/dca.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/dma/ioat/dca.c b/drivers/dma/ioat/dca.c
index 9b04185..9e84d5b 100644
--- a/drivers/dma/ioat/dca.c
+++ b/drivers/dma/ioat/dca.c
@@ -470,8 +470,10 @@ struct dca_provider *ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase)
 	}
 
 	if (!dca2_tag_map_valid(ioatdca->tag_map)) {
-		dev_err(&pdev->dev, "APICID_TAG_MAP set incorrectly by BIOS, "
-			"disabling DCA\n");
+		WARN_TAINT_ONCE(1, TAINT_FIRMWARE_WORKAROUND,
+				"%s %s: APICID_TAG_MAP set incorrectly by BIOS, disabling DCA\n",
+				dev_driver_string(&pdev->dev),
+				dev_name(&pdev->dev));
 		free_dca_provider(dca);
 		return NULL;
 	}
@@ -689,7 +691,10 @@ struct dca_provider *ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase)
 	}
 
 	if (dca3_tag_map_invalid(ioatdca->tag_map)) {
-		dev_err(&pdev->dev, "APICID_TAG_MAP set incorrectly by BIOS, disabling DCA\n");
+		WARN_TAINT_ONCE(1, TAINT_FIRMWARE_WORKAROUND,
+				"%s %s: APICID_TAG_MAP set incorrectly by BIOS, disabling DCA\n",
+				dev_driver_string(&pdev->dev),
+				dev_name(&pdev->dev));
 		free_dca_provider(dca);
 		return NULL;
 	}
