From: janitor@sternwelten.at
Subject: [patch 14/18]  s390/ctctty: replace 	schedule_timeout() with msleep_interruptible()
Date: Sun, 31 Oct 2004 00:43:03 +0200
Message-ID: <E1CO1w8-0002bI-A9@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com,
        schwidefsky@de.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep_interruptible() instead of
schedule_timeout() to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/s390/net/ctctty.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/s390/net/ctctty.c~msleep_interruptible-drivers_s390_net_ctctty drivers/s390/net/ctctty.c
--- linux-2.6.10-rc1/drivers/s390/net/ctctty.c~msleep_interruptible-drivers_s390_net_ctctty	2004-10-24 17:05:21.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/s390/net/ctctty.c	2004-10-24 17:05:21.000000000 +0200
@@ -1057,8 +1057,7 @@ ctc_tty_close(struct tty_struct *tty, st
 	info->tty = 0;
 	tty->closing = 0;
 	if (info->blocked_open) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		schedule_timeout(HZ/2);
+		msleep_interruptible(500);
 		wake_up_interruptible(&info->open_wait);
 	}
 	info->flags &= ~(CTC_ASYNC_NORMAL_ACTIVE | CTC_ASYNC_CLOSING);
_
