From: domen@coderock.org
Subject: [patch 18/19] net/ewrk3: replace schedule_timeout() with msleep_interruptible()
Date: Wed, 12 Jan 2005 00:11:03 +0100
Message-ID: <20050111231103.C176C1F234@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com
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
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/ewrk3.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/ewrk3.c~msleep_interruptible-drivers_net_ewrk3 drivers/net/ewrk3.c
--- kj/drivers/net/ewrk3.c~msleep_interruptible-drivers_net_ewrk3	2005-01-10 18:00:24.000000000 +0100
+++ kj-domen/drivers/net/ewrk3.c	2005-01-10 18:00:24.000000000 +0100
@@ -1654,8 +1654,7 @@ static int ewrk3_phys_id(struct net_devi
 
 		/* Wait a little while */
 		spin_unlock_irqrestore(&lp->hw_lock, flags);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(HZ>>2);
+		msleep(250);
 		spin_lock_irqsave(&lp->hw_lock, flags);
 
 		/* Exit if we got a signal */
_
