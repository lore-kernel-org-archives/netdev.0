From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 10/24] TTY: ircomm, use tty_port_close_end helper
Date: Mon,  4 Jun 2012 13:35:24 +0200
Message-ID: <1338809738-18967-11-git-send-email-jslaby@suse.cz>
References: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Cc: alan@linux.intel.com, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338809738-18967-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Again, the code is identical, so leverage the helper code.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 net/irda/ircomm/ircomm_tty.c |   16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty.c b/net/irda/ircomm/ircomm_tty.c
index 3fdce18..cfe352d 100644
--- a/net/irda/ircomm/ircomm_tty.c
+++ b/net/irda/ircomm/ircomm_tty.c
@@ -568,21 +568,7 @@ static void ircomm_tty_close(struct tty_struct *tty, struct file *filp)
 	tty_driver_flush_buffer(tty);
 	tty_ldisc_flush(tty);
 
-	spin_lock_irqsave(&port->lock, flags);
-	tty->closing = 0;
-
-	if (port->blocked_open) {
-		if (port->close_delay) {
-			spin_unlock_irqrestore(&port->lock, flags);
-			schedule_timeout_interruptible(port->close_delay);
-			spin_lock_irqsave(&port->lock, flags);
-		}
-		wake_up_interruptible(&port->open_wait);
-	}
-
-	port->flags &= ~(ASYNC_NORMAL_ACTIVE|ASYNC_CLOSING);
-	spin_unlock_irqrestore(&port->lock, flags);
-	wake_up_interruptible(&port->close_wait);
+	tty_port_close_end(port, tty);
 	tty_port_tty_set(port, NULL);
 }
 
-- 
1.7.10.3
