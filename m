From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Fix possible memory leak on iov error flow
Date: Thu, 27 Mar 2014 13:46:37 +0200
Message-ID: <1395920797-11199-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:55779 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753876AbaC0Lqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 07:46:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2dc33bbc4 "bnx2x: Remove the sriov VFOP mechanism" introduced a possible
memory leak on the error flow during multicast filters configuration.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please consider applying this to net-next.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index df15072..5c523b3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -595,6 +595,8 @@ int bnx2x_vf_mcast(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	rc = bnx2x_config_mcast(bp, &mcast, BNX2X_MCAST_CMD_DEL);
 	if (rc) {
 		BNX2X_ERR("Failed to remove multicasts\n");
+		if (mc)
+			kfree(mc);
 		return rc;
 	}
 
-- 
1.8.1.4
