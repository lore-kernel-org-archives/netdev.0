From: janitor@sternwelten.at
Subject: [patch 09/18]  net/ewrk3: replace schedule_timeout() with 	msleep_interruptible()
Date: Sun, 31 Oct 2004 00:42:46 +0200
Message-ID: <E1CO1vq-0002HF-E8@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be, as always, appreciated.

-Nish

Description: Uses msleep() instead of schedule_timeout() to guarantee
the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---

 linux-2.6.10-rc1-max/drivers/net/ewrk3.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/ewrk3.c~msleep_interruptible-drivers_net_ewrk3 drivers/net/ewrk3.c
--- linux-2.6.10-rc1/drivers/net/ewrk3.c~msleep_interruptible-drivers_net_ewrk3	2004-10-24 17:06:20.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/ewrk3.c	2004-10-24 17:06:20.000000000 +0200
@@ -1655,8 +1655,7 @@ static int ewrk3_phys_id(struct net_devi
 
 		/* Wait a little while */
 		spin_unlock_irqrestore(&lp->hw_lock, flags);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ>>2);
+		msleep(250);
 		spin_lock_irqsave(&lp->hw_lock, flags);
 
 		/* Exit if we got a signal */
_
