From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 39/58] appletalk: Remove unneeded synchronization
Date: Mon, 16 Oct 2017 17:29:23 -0700
Message-ID: <1508200182-104605-40-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of del_timer_sync() will make sure a timer is not rescheduled.
As such, there is no need to add external signals to kill timers. In
preparation for switching the timer callback argument to the timer
pointer, this drops the .data argument since it doesn't serve a meaningful
purpose here.

Cc: David Howells <dhowells@redhat.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/appletalk/ltpc.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index e4aa374caa4d..cc3dc9337eae 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -880,14 +880,10 @@ static void ltpc_poll(unsigned long l)
 		}
 		ltpc_poll_counter--;
 	}
-  
-	if (!dev)
-		return;  /* we've been downed */
 
 	/* poll 20 times per second */
 	idle(dev);
 	ltpc_timer.expires = jiffies + HZ/20;
-	
 	add_timer(&ltpc_timer);
 }
 
@@ -1252,8 +1248,6 @@ static void __exit ltpc_cleanup(void)
 	if(debug & DEBUG_VERBOSE) printk("unregister_netdev\n");
 	unregister_netdev(dev_ltpc);
 
-	ltpc_timer.data = 0;  /* signal the poll routine that we're done */
-
 	del_timer_sync(&ltpc_timer);
 
 	if(debug & DEBUG_VERBOSE) printk("freeing irq\n");
-- 
2.7.4
