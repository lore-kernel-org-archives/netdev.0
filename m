From: janitor@sternwelten.at
Subject: [patch 7/8]  wireless/airport: replace 	schedule_timeout() with msleep()
Date: Wed, 01 Sep 2004 23:05:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2cIm-00083E-M9@sputnik>
Cc: jgarzik@pobox.com, jt@hpl.hp.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org







I would appreciate any comments from the janitor@sternweltens list. 



Description: Use msleep() instead of schedule_timeout() to guarantee
the task delays for the desired time.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/wireless/airport.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff -puN drivers/net/wireless/airport.c~msleep-drivers_net_wireless_airport drivers/net/wireless/airport.c
--- linux-2.6.9-rc1-bk7/drivers/net/wireless/airport.c~msleep-drivers_net_wireless_airport	2004-09-01 19:35:41.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/wireless/airport.c	2004-09-01 19:35:41.000000000 +0200
@@ -94,8 +94,7 @@ airport_resume(struct macio_dev *mdev)
 	printk(KERN_DEBUG "%s: Airport waking up\n", dev->name);
 
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(mdev), 0, 1);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ/5);
+	msleep(200);
 
 	enable_irq(dev->irq);
 
@@ -147,8 +146,7 @@ airport_detach(struct macio_dev *mdev)
 	macio_release_resource(mdev, 0);
 
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(mdev), 0, 0);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ);
+	msleep(1000);
 
 	macio_set_drvdata(mdev, NULL);
 	free_netdev(dev);
@@ -174,11 +172,9 @@ static int airport_hard_reset(struct ori
 	disable_irq(dev->irq);
 
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(card->mdev), 0, 0);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ);
+	msleep(1000);
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(card->mdev), 0, 1);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ);
+	msleep(1000);
 
 	enable_irq(dev->irq);
 	schedule_timeout(HZ);
@@ -240,8 +236,7 @@ airport_attach(struct macio_dev *mdev, c
 		
 	/* Power up card */
 	pmac_call_feature(PMAC_FTR_AIRPORT_ENABLE, macio_get_of_node(mdev), 0, 1);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ);
+	msleep(1000);
 
 	/* Reset it before we get the interrupt */
 	hermes_init(hw);

_
