From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] ioat/dca: Update DCA BIOS workarounds to use
 TAINT_FIRMWARE_WORKAROUND
Date: Thu, 21 Mar 2013 13:55:03 -0700
Message-ID: <20130321205503.14096.95867.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: david.woodhouse@intel.com, jeffrey.t.kirsher@intel.com,
	gospo@redhat.com, bhutchings@solarflare.com, davem@davemloft.net,
	sassmann@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3816 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177Ab3CUU5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 16:57:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the DCA workarounds for broken BIOSes will now
use WARN_TAINT_ONCE(1, TAINT_FIRMWARE_WORKAROUND, ...) instead of just
printing a message via dev_err.  This is more appropriate since we are working
around a sever bug in the BIOS which is the intention of this call.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
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
