From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/8] tg3: Revert RSS indir tbl setup change
Date: Sun, 11 Jul 2010 12:31:40 -0700
Message-ID: <1278876707-21390-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1310 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754675Ab0GKTb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jul 2010 15:31:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reverts commit 2601d8a0049c8b5d29cd5adb844a305a804e505f.  A
spectacular set of coincidences made it look as though the table was
setup incorrectly.  The original version was correct.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index aa2d64f..89aa486 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8237,7 +8237,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++) {
 			int idx = i % sizeof(val);
 
-			ent[idx] = (i % (tp->irq_cnt - 1)) + 1;
+			ent[idx] = i % (tp->irq_cnt - 1);
 			if (idx == sizeof(val) - 1) {
 				tw32(reg, val);
 				reg += 4;
-- 
1.6.4.4


