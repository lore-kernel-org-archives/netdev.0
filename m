From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/4] bnx2: Always enable MSI-X on 5709.
Date: Sat, 3 Jul 2010 23:42:15 -0700
Message-ID: <1278225738-7795-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3306 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754967Ab0GDGjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jul 2010 02:39:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor change to use MSI-X even if there is only one CPU.  This allows
the CNIC driver to always have a dedicated MSI-X vector to handle
iSCSI events, instead of sharing the MSI vector.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a5dd81f..0614ca0 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6185,7 +6185,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 	bp->irq_nvecs = 1;
 	bp->irq_tbl[0].vector = bp->pdev->irq;
 
-	if ((bp->flags & BNX2_FLAG_MSIX_CAP) && !dis_msi && cpus > 1)
+	if ((bp->flags & BNX2_FLAG_MSIX_CAP) && !dis_msi)
 		bnx2_enable_msix(bp, msix_vecs);
 
 	if ((bp->flags & BNX2_FLAG_MSI_CAP) && !dis_msi &&
-- 
1.6.4.GIT


