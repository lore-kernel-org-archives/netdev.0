From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/4] qed: Enlrage the drain timeout
Date: Wed, 9 Mar 2016 09:16:26 +0200
Message-ID: <1457507786-6603-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37671 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752583AbcCIHRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 02:17:01 -0500
In-Reply-To: <1457507786-6603-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the scenario where slowpath configuration isn't passing due to
various pause configurations affecting the chip, the theoretical time
required in worst-case-scenario to empty hw fifos sufficiently to
guarantee that slowpath configuration would flow is currently
insufficient.

This increases such a drain request to the theoretical maximum.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 39c831d..b89c9a8 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -899,11 +899,11 @@ int qed_mcp_drain(struct qed_hwfn *p_hwfn,
 	int rc;
 
 	rc = qed_mcp_cmd(p_hwfn, p_ptt,
-			 DRV_MSG_CODE_NIG_DRAIN, 100,
+			 DRV_MSG_CODE_NIG_DRAIN, 1000,
 			 &resp, &param);
 
 	/* Wait for the drain to complete before returning */
-	msleep(120);
+	msleep(1020);
 
 	return rc;
 }
-- 
1.9.3
