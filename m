From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 07/10] bnx2x: disable loacal BH when scheduling FCOE
 napi
Date: Tue, 19 Jul 2011 14:43:25 +0300
Message-ID: <1311075805.30287.9.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1412 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332Ab1GSLum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 07:50:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index a86517c..b8f8793 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4520,8 +4520,15 @@ static void bnx2x_sp_task(struct work_struct *work)
 		struct bnx2x_fastpath *fp = bnx2x_fcoe_fp(bp);
 
 		if ((!NO_FCOE(bp)) &&
-			(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp)))
+			(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+			/*
+			 * Prevent local bottom-halves from running as
+			 * we are going to change the local NAPI list.
+			 */
+			local_bh_disable();
 			napi_schedule(&bnx2x_fcoe(bp, napi));
+			local_bh_enable();
+		}
 #endif
 		/* Handle EQ completions */
 		bnx2x_eq_int(bp);
-- 
1.7.2.2




