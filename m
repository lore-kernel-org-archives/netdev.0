From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] phylib: Fix delay argument of schedule_delayed_work
Date: Thu, 16 Apr 2009 01:05:51 +0900
Message-ID: <1239811551-6101-1-git-send-email-anemo@mba.ocn.ne.jp>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcin Slusarz <marcin.slusarz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:63629 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbZDOQFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 12:05:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit a390d1f3 ("phylib: convert state_queue work to
delayed_work") missed converting 'expires' value to 'delay' value.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/phy/phy.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3ff1f42..5737b85 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -434,7 +434,7 @@ void phy_start_machine(struct phy_device *phydev,
 	phydev->adjust_state = handler;
 
 	INIT_DELAYED_WORK(&phydev->state_queue, phy_state_machine);
-	schedule_delayed_work(&phydev->state_queue, jiffies + HZ);
+	schedule_delayed_work(&phydev->state_queue, HZ);
 }
 
 /**
@@ -937,6 +937,5 @@ static void phy_state_machine(struct work_struct *work)
 	if (err < 0)
 		phy_error(phydev);
 
-	schedule_delayed_work(&phydev->state_queue,
-				jiffies + PHY_STATE_TIME * HZ);
+	schedule_delayed_work(&phydev->state_queue, PHY_STATE_TIME * HZ);
 }
-- 
1.5.6.3

