From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 04/10] tg3: Off-by-one error in RSS setup
Date: Sat, 5 Jun 2010 20:24:33 -0700
Message-ID: <1275794679-11085-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4664 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933979Ab0FFDYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 23:24:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was incorrectly programming the indirection table such that
rx traffic intended for the second ring went to the first ring, rx
traffic intended for the third ring went to the second ring, etc.  This
patch changes the code so that rx traffic is diverted to the proper
ring.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 86f8798..3dccc58 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8228,7 +8228,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++) {
 			int idx = i % sizeof(val);
 
-			ent[idx] = i % (tp->irq_cnt - 1);
+			ent[idx] = (i % (tp->irq_cnt - 1)) + 1;
 			if (idx == sizeof(val) - 1) {
 				tw32(reg, val);
 				reg += 4;
-- 
1.6.4.4


