From: domen@coderock.org
Subject: [patch 1/1] net/3c505: replace schedule_timeout() with msleep()
Date: Wed, 12 Jan 2005 00:00:07 +0100
Message-ID: <20050111230007.F3BCF1F225@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com, pb@nexus.co.uk,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: philb@gnu.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() instead of schedule_timeout()
to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Phil Blundell <pb@nexus.co.uk>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/3c505.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff -puN drivers/net/3c505.c~msleep-drivers_net_3c505 drivers/net/3c505.c
--- kj/drivers/net/3c505.c~msleep-drivers_net_3c505	2005-01-10 17:59:58.000000000 +0100
+++ kj-domen/drivers/net/3c505.c	2005-01-10 17:59:58.000000000 +0100
@@ -1317,8 +1317,7 @@ static int __init elp_sense(struct net_d
 	if (orig_HSR & DIR) {
 		/* If HCR.DIR is up, we pull it down. HSR.DIR should follow. */
 		outb(0, dev->base_addr + PORT_CONTROL);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(30*HZ/100);
+		msleep(300);
 		if (inb_status(addr) & DIR) {
 			if (elp_debug > 0)
 				printk(notfound_msg, 2);
@@ -1327,8 +1326,7 @@ static int __init elp_sense(struct net_d
 	} else {
 		/* If HCR.DIR is down, we pull it up. HSR.DIR should follow. */
 		outb(DIR, dev->base_addr + PORT_CONTROL);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(30*HZ/100);
+		msleep(300);
 		if (!(inb_status(addr) & DIR)) {
 			if (elp_debug > 0)
 				printk(notfound_msg, 3);
_
