From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] bnx2: Fix accidental reversions.
Date: Tue, 11 Dec 2012 18:24:20 -0800
Message-ID: <1355279060-24192-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1516 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754212Ab2LLCI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2012 21:08:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4ce45e02469c382699f4c5f6df727aea9dd2e1ca
"bnx2: Add BNX2 prefix to CHIP ID and name macros"

accidentally reverted 2 commits to use pci_ioumap() and to make
pci_error_handlers const.  This fixes those mistakes.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index c16526d..a1adfaf 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8572,7 +8572,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 error:
-	iounmap(bp->regview);
+	pci_iounmap(pdev, bp->regview);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
@@ -8750,7 +8750,7 @@ static void bnx2_io_resume(struct pci_dev *pdev)
 	rtnl_unlock();
 }
 
-static struct pci_error_handlers bnx2_err_handler = {
+static const struct pci_error_handlers bnx2_err_handler = {
 	.error_detected	= bnx2_io_error_detected,
 	.slot_reset	= bnx2_io_slot_reset,
 	.resume		= bnx2_io_resume,
-- 
1.6.4.GIT
