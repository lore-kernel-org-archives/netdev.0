From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/13) aarp - del_timer_sync
Date: Fri, 29 Aug 2003 14:00:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829140058.772e5350.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Aarp module unload needs to use del_timer_sync to handle the
race condition where timer starts or is running during module
unload.

diff -Nru a/net/appletalk/aarp.c b/net/appletalk/aarp.c
--- a/net/appletalk/aarp.c	Fri Aug 29 13:31:18 2003
+++ b/net/appletalk/aarp.c	Fri Aug 29 13:31:18 2003
@@ -981,7 +981,7 @@
 /* General module cleanup. Called from cleanup_module() in ddp.c. */
 void aarp_cleanup_module(void)
 {
-	del_timer(&aarp_timer);
+	del_timer_sync(&aarp_timer);
 	unregister_netdevice_notifier(&aarp_notifier);
 	unregister_snap_client(aarp_dl);
 	aarp_purge();
