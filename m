From: domen@coderock.org
Subject: [patch 05/19] net/ma600-sir: replace schedule_timeout() with msleep()
Date: Wed, 12 Jan 2005 00:10:21 +0100
Message-ID: <20050111231021.B96BB1F22B@trashy.coderock.org>
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


 kj-domen/drivers/net/irda/ma600-sir.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff -puN drivers/net/irda/ma600-sir.c~msleep-drivers_net_irda_ma600-sir drivers/net/irda/ma600-sir.c
--- kj/drivers/net/irda/ma600-sir.c~msleep-drivers_net_irda_ma600-sir	2005-01-10 18:00:00.000000000 +0100
+++ kj-domen/drivers/net/irda/ma600-sir.c	2005-01-10 18:00:00.000000000 +0100
@@ -191,8 +191,7 @@ static int ma600_change_speed(struct sir
 	sirdev_raw_write(dev, &byte, sizeof(byte));
 
 	/* Wait at least 10ms: fake wait_until_sent - 10 bits at 9600 baud*/
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(15));		/* old ma600 uses 15ms */
+	msleep(15);					/* old ma600 uses 15ms */
 
 #if 1
 	/* read-back of the control byte. ma600 is the first dongle driver
@@ -215,8 +214,7 @@ static int ma600_change_speed(struct sir
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
 	/* Wait at least 10ms */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(10));
+	msleep(10);
 
 	/* dongle is now switched to the new speed */
 	dev->speed = speed;
@@ -245,13 +243,11 @@ int ma600_reset(struct sir_dev *dev)
 
 	/* Reset the dongle : set DTR low for 10 ms */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(10));
+	msleep(10);
 
 	/* Go back to normal mode */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(msecs_to_jiffies(10));
+	msleep(10);
 
 	dev->speed = 9600;      /* That's the dongle-default */
 
_
