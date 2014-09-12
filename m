From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 8/8] be2net: enable PCIe error reporting on VFs too
Date: Fri, 12 Sep 2014 17:39:21 +0530
Message-ID: <1410523761-1744-9-git-send-email-sathya.perla@emulex.com>
References: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:21722 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754561AbaILMGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 08:06:49 -0400
In-Reply-To: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Currently PCIe error reporting is enabled only on PFs. This patch enables
this feature on VFs too as Lancer VFs support it.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a6cf6c7..beebab6 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4877,11 +4877,9 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 		}
 	}
 
-	if (be_physfn(adapter)) {
-		status = pci_enable_pcie_error_reporting(pdev);
-		if (!status)
-			dev_info(&pdev->dev, "PCIe error reporting enabled\n");
-	}
+	status = pci_enable_pcie_error_reporting(pdev);
+	if (!status)
+		dev_info(&pdev->dev, "PCIe error reporting enabled\n");
 
 	status = be_ctrl_init(adapter);
 	if (status)
-- 
1.7.1
