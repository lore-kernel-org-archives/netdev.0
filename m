From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/8] tg3: Futureproof the loopback test
Date: Thu, 30 Sep 2010 13:34:34 -0700
Message-ID: <1285878877-12148-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4670 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756628Ab0I3Uey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 16:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are other multiqueue modes 5717 and 5719 devices can assume.  This
patch makes sure that the loopback test is safe, should those other
modes be enabled in the future.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d76e718..50b7e35 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10642,7 +10642,8 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	tnapi = &tp->napi[0];
 	rnapi = &tp->napi[0];
 	if (tp->irq_cnt > 1) {
-		rnapi = &tp->napi[1];
+		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS)
+			rnapi = &tp->napi[1];
 		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_TSS)
 			tnapi = &tp->napi[1];
 	}
-- 
1.7.2.2


