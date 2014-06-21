From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 07/11] tlan: Make autonegotiation faster
Date: Sat, 21 Jun 2014 16:47:52 +0200
Message-ID: <1403362076-7777-8-git-send-email-linux@rainbow-software.org>
References: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the autonegotiation poll interval from 8 seconds to 2.
This greatly reduces the time needed to detect link presence,
especially on Olicom cards at 10 Mbps (two autonegoatiations required).

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 6d9898f..b4e9dcf 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -2699,7 +2699,7 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
 		/* Wait for 8 sec to give the process
 		 * more time.  Perhaps we should fail after a while.
 		 */
-		tlan_set_timer(dev, (8*HZ), TLAN_TIMER_PHY_FINISH_AN);
+		tlan_set_timer(dev, 2 * HZ, TLAN_TIMER_PHY_FINISH_AN);
 		return;
 	}
 
-- 
Ondrej Zary
