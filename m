From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net v2] bnx2x: fix napi poll return value for repoll
Date: Sun, 25 Jan 2015 16:09:23 +0530
Message-ID: <1422182363-10932-1-git-send-email-_govind@gmx.com>
Cc: edumazet@google.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, ariel.elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:49348 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbbAYKj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 05:39:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the commit d75b1ade567ffab ("net: less interrupt masking in NAPI") napi
repoll is done only when work_done == budget. When in busy_poll is we return 0
in napi_poll. We should return budget.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
v2:
Remove unnecessary change for work_done >= budget return value.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 1d1147c..e468ed3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3175,7 +3175,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 		}
 #endif
 		if (!bnx2x_fp_lock_napi(fp))
-			return work_done;
+			return budget;
 
 		for_each_cos_in_tx_queue(fp, cos)
 			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
-- 
2.2.2
