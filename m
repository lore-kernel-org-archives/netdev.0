From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] get rid of dev_get in wanrouter
Date: Mon, 15 Sep 2003 17:10:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915171036.3099c6ee.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nenad Corbic <ncorbic@sangoma.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This call to dev_get() is racy and unnecessary because register_netdevice checks
if device already exists.

diff -Nru a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
--- a/net/wanrouter/wanmain.c	Mon Sep 15 17:06:43 2003
+++ b/net/wanrouter/wanmain.c	Mon Sep 15 17:06:43 2003
@@ -727,8 +727,6 @@
 
 		if (dev->name == NULL) {
 			err = -EINVAL;
-		} else if (dev_get(dev->name)) {
-			err = -EEXIST;	/* name already exists */
 		} else {
 
 			#ifdef WANDEBUG
