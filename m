From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Eliminate MOD_ from wanrouter
Date: Fri, 18 Jul 2003 13:35:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030718133512.434b1e70.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nenad Corbic <ncorbic@sangoma.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wan router register/unregister doesn't need MOD_INC/MOD_DEC because it
can't be unloaded as long as it's symbols are in use by the calling module.

Patch against 2.6.0-test1

diff -Nru a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
--- a/net/wanrouter/wanmain.c	Fri Jul 18 13:20:48 2003
+++ b/net/wanrouter/wanmain.c	Fri Jul 18 13:20:48 2003
@@ -305,7 +305,6 @@
 	wandev->dev  = NULL;
 	wandev->next = wanrouter_router_devlist;
 	wanrouter_router_devlist = wandev;
-        MOD_INC_USE_COUNT;	/* prevent module from unloading */
 	return 0;
 }
 
@@ -350,7 +349,6 @@
 		wanrouter_router_devlist = wandev->next;
 
 	wanrouter_proc_delete(wandev);
-        MOD_DEC_USE_COUNT;
 	return 0;
 }
 
