From: domen@coderock.org
Subject: [patch 1/1] net/pcnet32: replace schedule_timeout() with msleep_interruptible()
Date: Wed, 12 Jan 2005 00:01:49 +0100
Message-ID: <20050111230150.1B6141F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep_interruptible() instead of schedule_timeout() to
guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/pcnet32.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32 drivers/net/pcnet32.c
--- kj/drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32	2005-01-10 18:00:07.000000000 +0100
+++ kj-domen/drivers/net/pcnet32.c	2005-01-10 18:00:07.000000000 +0100
@@ -847,7 +847,7 @@ static int pcnet32_phys_id(struct net_de
     if ((!data) || (data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ)))
     data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
 
-    schedule_timeout(data * HZ);
+    msleep_interruptible(data * 1000);
     del_timer_sync(&lp->blink_timer);
 
     /* Restore the original value of the bcrs */
_
