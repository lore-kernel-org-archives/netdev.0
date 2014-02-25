From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next 3/3] bnx2x: save RAM in kdump kernel by disabling TPA
Date: Tue, 25 Feb 2014 16:04:26 +0100
Message-ID: <1393340666-3539-4-git-send-email-mschmidt@redhat.com>
References: <1393340666-3539-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, ariele@broadcom.com, dmitry@broadcom.com,
	yuvalmin@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935AbaBYPEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 10:04:38 -0500
In-Reply-To: <1393340666-3539-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in a kdump kernel, disable TPA. This saves memory, which
tends to be scarce in kdump.

TPA, being a receive acceleration, is unlikely to be useful for kdump,
whose purpose is to send the memory image out.

This saves additional 5 MB in the kdump environment.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 8443915..13de536 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11783,6 +11783,8 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 
 	bp->disable_tpa = disable_tpa;
 	bp->disable_tpa |= IS_MF_STORAGE_SD(bp) || IS_MF_FCOE_AFEX(bp);
+	/* Reduce memory usage in kdump environment by disabling TPA */
+	bp->disable_tpa |= reset_devices;
 
 	/* Set TPA flags */
 	if (bp->disable_tpa) {
-- 
1.8.5.3
