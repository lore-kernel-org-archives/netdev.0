From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH] slip: remove unused 'line' field from the 'slip' structure
Date: Tue, 19 Jul 2011 11:56:44 +0400
Message-ID: <CAKh5nabuWJtnfM6PEOkGbEog89jmiAAiPPArV==2F5mX0PUH-Q@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:62907 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab1GSH5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 03:57:05 -0400
Received: by qyk29 with SMTP id 29so1919050qyk.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 00:57:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/slip.c |    3 ---
 drivers/net/slip.h |    1 -
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 2f110fb..77c4798 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -823,7 +823,6 @@ static int slip_open(struct tty_struct *tty)

 	sl->tty = tty;
 	tty->disc_data = sl;
-	sl->line = tty_devnum(tty);
 	sl->pid = current->pid;

 	if (!test_bit(SLF_INUSE, &sl->flags)) {
@@ -890,8 +889,6 @@ static void slip_close(struct tty_struct *tty)

 	tty->disc_data = NULL;
 	sl->tty = NULL;
-	if (!sl->leased)
-		sl->line = 0;

 	/* VSV = very important to remove timers */
 #ifdef CONFIG_SLIP_SMART
diff --git a/drivers/net/slip.h b/drivers/net/slip.h
index 914e958..aa0764c 100644
--- a/drivers/net/slip.h
+++ b/drivers/net/slip.h
@@ -90,7 +90,6 @@ struct slip {

   unsigned char		mode;		/* SLIP mode			*/
   unsigned char		leased;
-  dev_t			line;
   pid_t			pid;
 #define SL_MODE_SLIP	0
 #define SL_MODE_CSLIP	1
-- 
1.7.6
