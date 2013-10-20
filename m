From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net v2 6/9] bnx2x: Prevent null pointer dereference on
 error flow
Date: Sun, 20 Oct 2013 16:51:31 +0200
Message-ID: <1382280694-8428-7-git-send-email-yuvalmin@broadcom.com>
References: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2637 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab3JTOv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 10:51:59 -0400
In-Reply-To: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If debug message is open and bnx2x_vfop_qdtor_cmd() were to fail,
the resulting print would have caused a null pointer dereference.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 997c661..bf08ad6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -470,10 +470,10 @@ static int bnx2x_vfop_qdtor_cmd(struct bnx2x *bp,
 				 bnx2x_vfop_qdtor, cmd->done);
 		return bnx2x_vfop_transition(bp, vf, bnx2x_vfop_qdtor,
 					     cmd->block);
+	} else {
+		BNX2X_ERR("VF[%d] failed to add a vfop\n", vf->abs_vfid);
+		return -ENOMEM;
 	}
-	DP(BNX2X_MSG_IOV, "VF[%d] failed to add a vfop. rc %d\n",
-	   vf->abs_vfid, vfop->rc);
-	return -ENOMEM;
 }
 
 static void
-- 
1.8.1.227.g44fe835
