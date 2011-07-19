From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH] slcan: remove unused 'leased', 'line' and 'pid' fields from
 the 'slcan' structure
Date: Tue, 19 Jul 2011 11:58:48 +0400
Message-ID: <CAKh5naa=x13=wUE+MLAYv0XQ4OhuY5G47ZDmFz0vbkibNtoz-A@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:48051 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab1GSH7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 03:59:08 -0400
Received: by qwk3 with SMTP id 3so1864981qwk.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 00:59:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
---
 drivers/net/can/slcan.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 1b49df6..805ee29 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -95,10 +95,6 @@ struct slcan {
 	unsigned long		flags;		/* Flag values/ mode etc     */
 #define SLF_INUSE		0		/* Channel in use            */
 #define SLF_ERROR		1               /* Parity, etc. error        */
-
-	unsigned char		leased;
-	dev_t			line;
-	pid_t			pid;
 };

 static struct net_device **slcan_devs;
@@ -462,7 +458,7 @@ static void slc_sync(void)
 			break;

 		sl = netdev_priv(dev);
-		if (sl->tty || sl->leased)
+		if (sl->tty)
 			continue;
 		if (dev->flags & IFF_UP)
 			dev_close(dev);
@@ -565,8 +561,6 @@ static int slcan_open(struct tty_struct *tty)

 	sl->tty = tty;
 	tty->disc_data = sl;
-	sl->line = tty_devnum(tty);
-	sl->pid = current->pid;

 	if (!test_bit(SLF_INUSE, &sl->flags)) {
 		/* Perform the low-level SLCAN initialization. */
@@ -617,8 +611,6 @@ static void slcan_close(struct tty_struct *tty)

 	tty->disc_data = NULL;
 	sl->tty = NULL;
-	if (!sl->leased)
-		sl->line = 0;

 	/* Flush network side */
 	unregister_netdev(sl->dev);
-- 
1.7.6
