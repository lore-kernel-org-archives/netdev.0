From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc3] dev_close: use of netif_poll_disable
Date: Sat, 2 Oct 2004 22:28:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041002202805.GA16870@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use of identical (comment included) netif_poll_disable().

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN net/core/dev.c~dev_close-cleanup net/core/dev.c
--- linux-2.6.9-rc3/net/core/dev.c~dev_close-cleanup	2004-10-02 22:14:29.000000000 +0200
+++ linux-2.6.9-rc3-fr/net/core/dev.c	2004-10-02 22:16:02.000000000 +0200
@@ -959,11 +959,8 @@ int dev_close(struct net_device *dev)
 	 * engine, but this requires more changes in devices. */
 
 	smp_mb__after_clear_bit(); /* Commit netif_running(). */
-	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
-		/* No hurry. */
-		current->state = TASK_INTERRUPTIBLE;
-		schedule_timeout(1);
-	}
+
+	netif_poll_disable(dev);
 
 	/*
 	 *	Call the device specific close. This cannot fail.

_
