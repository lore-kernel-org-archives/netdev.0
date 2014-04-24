From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 3/3] bnx2x: Fix failure to configure VF multicast filters
Date: Thu, 24 Apr 2014 19:29:54 +0300
Message-ID: <1398356994-30759-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1398356994-30759-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>,
	Narender Kumar <narender.kumar@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:22032 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753906AbaDXQaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 12:30:18 -0400
In-Reply-To: <1398356994-30759-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narender Kumar <narender.kumar@qlogic.com>

Commit 2dc33bbc "bnx2x: Remove the sriov VFOP mechanism" caused a regression,
preventing VFs from configuring multicast filters.

Signed-off-by: Naredner Kumar <narender.kumar@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index eefe8f5..81cc2d9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -612,6 +612,7 @@ int bnx2x_vf_mcast(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		}
 
 		/* add new mcasts */
+		mcast.mcast_list_len = mc_num;
 		rc = bnx2x_config_mcast(bp, &mcast, BNX2X_MCAST_CMD_ADD);
 		if (rc)
 			BNX2X_ERR("Faled to add multicasts\n");
-- 
1.8.1.4
