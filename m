From: domen@coderock.org
Subject: [patch 03/19] net/act2001-sir: replace schedule_timeout() with msleep()
Date: Wed, 12 Jan 2005 00:10:14 +0100
Message-ID: <20050111231015.44F491F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() instead of schedule_timeout()
to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/irda/act200l-sir.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/irda/act200l-sir.c~msleep-drivers_net_irda_act200l-sir drivers/net/irda/act200l-sir.c
--- kj/drivers/net/irda/act200l-sir.c~msleep-drivers_net_irda_act200l-sir	2005-01-10 17:59:59.000000000 +0100
+++ kj-domen/drivers/net/irda/act200l-sir.c	2005-01-10 17:59:59.000000000 +0100
@@ -177,8 +177,7 @@ static int act200l_change_speed(struct s
 
 	/* Write control bytes */
 	sirdev_raw_write(dev, control, 3);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(5));
+	msleep(5);
 
 	/* Go back to normal mode */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
_
