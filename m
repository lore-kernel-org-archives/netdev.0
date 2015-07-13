From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/2] isdn/gigaset: drop unused ldisc methods
Date: Tue, 14 Jul 2015 00:37:13 +0200 (CEST)
Message-ID: <40ceea060d328b84da061f115e7ed9b99d28cf74.1436826434.git.tilman@imap.cc>
References: <cover.1436826434.git.tilman@imap.cc>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>, linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1436826434.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The line discipline read and write methods are optional so the dummy
methods in ser_gigaset are unnecessary and can be removed.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ser-gigaset.c |   24 ------------------------
 1 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 3ac9c41..375be50 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -607,28 +607,6 @@ static int gigaset_tty_hangup(struct tty_struct *tty)
 }
 
 /*
- * Read on the tty.
- * Unused, received data goes only to the Gigaset driver.
- */
-static ssize_t
-gigaset_tty_read(struct tty_struct *tty, struct file *file,
-		 unsigned char __user *buf, size_t count)
-{
-	return -EAGAIN;
-}
-
-/*
- * Write on the tty.
- * Unused, transmit data comes only from the Gigaset driver.
- */
-static ssize_t
-gigaset_tty_write(struct tty_struct *tty, struct file *file,
-		  const unsigned char *buf, size_t count)
-{
-	return -EAGAIN;
-}
-
-/*
  * Ioctl on the tty.
  * Called in process context only.
  * May be re-entered by multiple ioctl calling threads.
@@ -761,8 +739,6 @@ static struct tty_ldisc_ops gigaset_ldisc = {
 	.open		= gigaset_tty_open,
 	.close		= gigaset_tty_close,
 	.hangup		= gigaset_tty_hangup,
-	.read		= gigaset_tty_read,
-	.write		= gigaset_tty_write,
 	.ioctl		= gigaset_tty_ioctl,
 	.receive_buf	= gigaset_tty_receive,
 	.write_wakeup	= gigaset_tty_wakeup,
-- 
1.7.1
