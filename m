From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net 1/2] enic: fix rx napi poll return value
Date: Tue, 20 Jan 2015 18:46:15 +0530
Message-ID: <1421759776-376-2-git-send-email-_govind@gmx.com>
References: <1421759776-376-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, ariel.elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:60459 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505AbbATNRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2015 08:17:24 -0500
In-Reply-To: <1421759776-376-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the commit d75b1ade567ffab ("net: less interrupt masking in NAPI") napi repoll
is done only when work_done == budget. When we are in busy_poll we return 0 in
napi_poll. We should return budget.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index b29e027..e356afa 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1335,7 +1335,7 @@ static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
 	int err;
 
 	if (!enic_poll_lock_napi(&enic->rq[rq]))
-		return work_done;
+		return budget;
 	/* Service RQ
 	 */
 
-- 
2.2.2
