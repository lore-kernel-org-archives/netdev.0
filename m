From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 01/14] tg3: Fix 5906 link problems
Date: Wed, 25 Feb 2009 16:21:20 -0800
Message-ID: <1235616367.15995@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2998 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753697AbZBZCqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6833c043f9fc03696fde623914c4a0277df2a0bc introduced the phy
auto-powerdown capability.  While the APD feature only works for 5761
and 5784 asic revisions, the (harmless portion of the) code was applied
to all 5705 and newer devices.  However, the 5906 phy departs from the
usual design.  This commit was interfering with the 5906's ability to
negotiate link against some switches.  This patch corrects the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 67630fb..c7bbbb1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1473,7 +1473,8 @@ static void tg3_phy_toggle_apd(struct tg3 *tp, bool enable)
 {
 	u32 reg;
 
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		return;
 
 	reg = MII_TG3_MISC_SHDW_WREN |
-- 
1.6.0.6


