From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 1/1] bnx2x: Fix AER semaphore release
Date: Wed, 27 Mar 2013 11:28:03 +0200
Message-ID: <1364376483-15050-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4315 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557Ab3C0KdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 06:33:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7fa6f34 "AER revised" erroneously inserted an error-flow
in which a semaphore is released even though the attempt to take it
has failed.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
Hi Dave,

Please accept this to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2c6a2a6..5c5a327 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10070,8 +10070,8 @@ static int bnx2x_prev_unload(struct bnx2x *bp)
 			/* If Path is marked by EEH, ignore unload status */
 			aer = !!(bnx2x_prev_path_get_entry(bp) &&
 				 bnx2x_prev_path_get_entry(bp)->aer);
+			up(&bnx2x_prev_sem);
 		}
-		up(&bnx2x_prev_sem);
 
 		if (fw == FW_MSG_CODE_DRV_UNLOAD_COMMON || aer) {
 			rc = bnx2x_prev_unload_common(bp);
-- 
1.8.1.227.g44fe835
