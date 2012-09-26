From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] bnx2: Clean up remaining iounmap
Date: Wed, 26 Sep 2012 13:22:02 -0400
Message-ID: <1348680122-9711-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Michael Chan <mcan@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53108 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab2IZRW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 13:22:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c0357e975afdbbedab5c662d19bef865f02adc17 modified bnx2 to switch from
using ioremap/iounmap to pci_iomap/pci_iounmap.  They missed a spot in the error
path of bnx2_init_one though.  This patch just cleans that up.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Michael Chan <mcan@broadcom.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/broadcom/bnx2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 79cebd8..e48312f 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8564,7 +8564,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 error:
-	iounmap(bp->regview);
+	pci_iounmap(pdev, bp->regview);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-- 
1.7.11.4
