From: janitor@sternwelten.at
Subject: [patch 3/8]  irda/ma600-sir: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:05:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cIQ-00080O-LF@sputnik>
Cc: jgarzik@pobox.com, jt@hpl.hp.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. 



Description: Replace schedule_timeout() with msleep() to guarantee the
task delays for the desired time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/irda/ma600-sir.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff -puN drivers/net/irda/ma600-sir.c~msleep-drivers_net_irda_ma600-sir drivers/net/irda/ma600-sir.c
--- linux-2.6.9-rc1-bk7/drivers/net/irda/ma600-sir.c~msleep-drivers_net_irda_ma600-sir	2004-09-01 19:35:32.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/irda/ma600-sir.c	2004-09-01 19:35:32.000000000 +0200
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
