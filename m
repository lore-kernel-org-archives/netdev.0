From: domen@coderock.org
Subject: [patch 10/19] net/ns83820: replace schedule_timeout() with msleep()
Date: Wed, 12 Jan 2005 00:10:37 +0100
Message-ID: <20050111231037.B8C8A1F22A@trashy.coderock.org>
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


 kj-domen/drivers/net/ns83820.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/ns83820.c~msleep-drivers_net_ns83820 drivers/net/ns83820.c
--- kj/drivers/net/ns83820.c~msleep-drivers_net_ns83820	2005-01-10 18:00:02.000000000 +0100
+++ kj-domen/drivers/net/ns83820.c	2005-01-10 18:00:02.000000000 +0100
@@ -2007,8 +2007,7 @@ static int __devinit ns83820_init_one(st
 	if (reset_phy) {
 		printk(KERN_INFO "%s: resetting phy\n", ndev->name);
 		writel(dev->CFG_cache | CFG_PHY_RST, dev->base + CFG);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout((HZ+99)/100);
+		msleep(10);
 		writel(dev->CFG_cache, dev->base + CFG);
 	}
 
_
