From: janitor@sternwelten.at
Subject: [patch 11/18]  net/pcnet32: replace 	schedule_timeout() with msleep_interruptible()
Date: Sun, 31 Oct 2004 00:42:53 +0200
Message-ID: <E1CO1vx-0002OW-FJ@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep_interruptible() instead of schedule_timeout() to
guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/pcnet32.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32 drivers/net/pcnet32.c
--- linux-2.6.10-rc1/drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32	2004-10-24 17:05:14.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/pcnet32.c	2004-10-24 17:05:14.000000000 +0200
@@ -847,7 +847,7 @@ static int pcnet32_phys_id(struct net_de
     if ((!data) || (data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ)))
     data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
 
-    schedule_timeout(data * HZ);
+    msleep_interruptible(data * 1000);
     del_timer_sync(&lp->blink_timer);
 
     /* Restore the original value of the bcrs */
_
