From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 7/7] tty: Remove wait_event_interruptible_tty()
Date: Sat, 10 Oct 2015 16:00:57 -0400
Message-ID: <1444507257-7513-8-git-send-email-peter@hurleysoftware.com>
References: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>, Alan Cox <alan@linux.intel.com>,
	David Laight <David.Laight@aculab.com>,
	Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33009 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbbJJUBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 16:01:30 -0400
Received: by qgew37 with SMTP id w37so36048669qge.0
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 13:01:29 -0700 (PDT)
In-Reply-To: <1444507257-7513-1-git-send-email-peter@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In-tree users of wait_event_interruptible_tty() have been removed;
remove.

Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 include/linux/tty.h | 26 --------------------------
 1 file changed, 26 deletions(-)

diff --git a/include/linux/tty.h b/include/linux/tty.h
index 090ce2a..c2889f4 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -655,32 +655,6 @@ extern void __lockfunc tty_unlock(struct tty_struct *tty);
 extern void __lockfunc tty_lock_slave(struct tty_struct *tty);
 extern void __lockfunc tty_unlock_slave(struct tty_struct *tty);
 extern void tty_set_lock_subclass(struct tty_struct *tty);
-/*
- * wait_event_interruptible_tty -- wait for a condition with the tty lock held
- *
- * The condition we are waiting for might take a long time to
- * become true, or might depend on another thread taking the
- * BTM. In either case, we need to drop the BTM to guarantee
- * forward progress. This is a leftover from the conversion
- * from the BKL and should eventually get removed as the BTM
- * falls out of use.
- *
- * Do not use in new code.
- */
-#define wait_event_interruptible_tty(tty, wq, condition)		\
-({									\
-	int __ret = 0;							\
-	if (!(condition))						\
-		__ret = __wait_event_interruptible_tty(tty, wq,		\
-						       condition);	\
-	__ret;								\
-})
-
-#define __wait_event_interruptible_tty(tty, wq, condition)		\
-	___wait_event(wq, condition, TASK_INTERRUPTIBLE, 0, 0,		\
-			tty_unlock(tty);				\
-			schedule();					\
-			tty_lock(tty))
 
 #ifdef CONFIG_PROC_FS
 extern void proc_tty_register_driver(struct tty_driver *);
-- 
2.6.1
