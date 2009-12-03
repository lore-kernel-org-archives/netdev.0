From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/6] tg3: Clean tg3_init_one()
Date: Thu, 3 Dec 2009 10:36:24 -0800
Message-ID: <1259865385-7773-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1198 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756159AbZLCSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 13:40:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tg3's firmware is no longer loaded from tg3_init_one().  Remove the
error path that releases the firmware back to the system.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 49c60f9..042e391 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -14483,7 +14483,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	if (err) {
 		printk(KERN_ERR PFX "Could not obtain valid ethernet address, "
 		       "aborting.\n");
-		goto err_out_fw;
+		goto err_out_iounmap;
 	}
 
 	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
@@ -14492,7 +14492,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 			printk(KERN_ERR PFX "Cannot map APE registers, "
 			       "aborting.\n");
 			err = -ENOMEM;
-			goto err_out_fw;
+			goto err_out_iounmap;
 		}
 
 		tg3_ape_lock_init(tp);
@@ -14623,10 +14623,6 @@ err_out_apeunmap:
 		tp->aperegs = NULL;
 	}
 
-err_out_fw:
-	if (tp->fw)
-		release_firmware(tp->fw);
-
 err_out_iounmap:
 	if (tp->regs) {
 		iounmap(tp->regs);
-- 
1.6.4.4


