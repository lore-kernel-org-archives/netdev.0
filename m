From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH next] be2net: Rework PCIe error report log messaging
Date: Fri, 18 Oct 2013 16:06:24 -0500
Message-ID: <20131018210624.GA3944@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [138.239.224.100] ([138.239.224.100]:55378 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752956Ab3JRVGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 17:06:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we log a message whenever pcie_enable_error_reporting fails.
The message clutters up logs, especially when we don't support it for VFs.
Instead enable this only for PFs and log a message when the call succeeds.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2d6115c..f0866e2 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4459,9 +4459,11 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 		}
 	}
 
-	status = pci_enable_pcie_error_reporting(pdev);
-	if (status)
-		dev_info(&pdev->dev, "Could not use PCIe error reporting\n");
+	if (be_physfn(adapter)) {
+		status = pci_enable_pcie_error_reporting(pdev);
+		if (!status)
+			dev_info(&pdev->dev, "PCIe error reporting enabled\n");
+	}
 
 	status = be_ctrl_init(adapter);
 	if (status)
-- 
1.8.1.2
