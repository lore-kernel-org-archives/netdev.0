From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/9] tg3: Reset phy during bringup when using phylib
Date: Fri, 12 Feb 2010 16:47:10 -0800
Message-ID: <1266022033-3546-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1324 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757164Ab0BMArk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 19:47:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver puts the phy into low-power mode when it releases the device.
If the device were to be reacquired, the phy needs a reset to bring it
back to full powered operation.  This patch allows phylib-enabled
devices to reset the phy.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1c545a8..9c4d88a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7595,8 +7595,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tg3_abort_hw(tp, 1);
 	}
 
-	if (reset_phy &&
-	    !(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB))
+	if (reset_phy)
 		tg3_phy_reset(tp);
 
 	err = tg3_chip_reset(tp);
-- 
1.6.4.4


