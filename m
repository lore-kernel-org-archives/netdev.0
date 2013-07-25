From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next] be2net: don't use dev_err when AER enabling fails
Date: Thu, 25 Jul 2013 16:10:55 +0200
Message-ID: <1374761455-28193-1-git-send-email-ivecera@redhat.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755649Ab3GYOLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 10:11:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver uses dev_err when enabling of AER fails (e.g. PCIe AER is not
supported). The dev_info is more appropriate to avoid console pollution.

Cc: sathya.perla@emulex.com
Cc: subbu.seetharaman@emulex.com
Cc: ajit.khaparde@emulex.com
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 67deb21..3df1503 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4232,7 +4232,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 
 	status = pci_enable_pcie_error_reporting(pdev);
 	if (status)
-		dev_err(&pdev->dev, "Could not use PCIe error reporting\n");
+		dev_info(&pdev->dev, "Could not use PCIe error reporting\n");
 
 	status = be_ctrl_init(adapter);
 	if (status)
-- 
1.8.1.5
