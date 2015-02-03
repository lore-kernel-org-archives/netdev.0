From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 2/2] tlan: msecs_to_jiffies convrsion
Date: Tue,  3 Feb 2015 03:45:11 -0500
Message-ID: <1422953111-19840-1-git-send-email-hofrat@osadl.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is only an API consolidation and should make things more readable
it replaces var * HZ / 1000 by msecs_to_jiffies(var).

As there is a discrepancy between the code and the comments this is in
a separate patch.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Converting milliseconds to jiffies by val * HZ / 1000 is technically
not wrong but msecs_to_jiffies(val) is the cleaner solution and handles
all corner cases correctly. This basically is a minor API cleanup only
but the comment and the code do not match ! Comments states "do the
longer, just in case" which would be 500 ms - the code though sets it
to HZ/20 == 50ms. This needs a review by someone that knows the driver
details to decide if it should be 50 or 500ms here.

Patch was only compile tested for x86_64_defconfig + CONFIG_TLAN=m

Patch is against 3.0.19-rc7 (localversion = -next-20150203)

 drivers/net/ethernet/ti/tlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 1f722c9..691ec93 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -2561,7 +2561,7 @@ static void tlan_phy_power_up(struct net_device *dev)
 	 * transceiver.  The TLAN docs say both 50 ms and
 	 * 500 ms, so do the longer, just in case.
 	 */
-	tlan_set_timer(dev, (HZ/20), TLAN_TIMER_PHY_RESET);
+	tlan_set_timer(dev, msecs_to_jiffies(500), TLAN_TIMER_PHY_RESET);
 
 }
 
-- 
1.7.10.4
