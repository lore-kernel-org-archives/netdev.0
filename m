From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/9] tg3: Fix napi assignments in loopback test
Date: Fri, 12 Feb 2010 16:47:11 -0800
Message-ID: <1266022033-3546-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1319 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757113Ab0BMArk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 19:47:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 57765 lacks TSS support.  This renders the napi assignments
incorrect in the loopback test function.  This patch fixes the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9c4d88a..74fa6d5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10780,12 +10780,12 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	struct tg3_napi *tnapi, *rnapi;
 	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
+	tnapi = &tp->napi[0];
+	rnapi = &tp->napi[0];
 	if (tp->irq_cnt > 1) {
-		tnapi = &tp->napi[1];
 		rnapi = &tp->napi[1];
-	} else {
-		tnapi = &tp->napi[0];
-		rnapi = &tp->napi[0];
+		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
+			tnapi = &tp->napi[1];
 	}
 	coal_now = tnapi->coal_now | rnapi->coal_now;
 
-- 
1.6.4.4


