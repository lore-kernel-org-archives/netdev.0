From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] remove dev_get from wanrouter
Date: Mon, 29 Sep 2003 14:36:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929143603.06d32058.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nenad Corbic <ncorbic@sangoma.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The call to dev_get() in wanrouter_device_new_if is racy and redundant and should
be removed.  The later 'register_netdev()' does the same test internally and will
return the appropriate error if the name already exists.

This patch is against 2.6.0-test6.
Resend of earlier patch because it was ignored, or missed.

diff -urN -X dontdiff linux-2.5/net/wanrouter/wanmain.c linux-2.5-net/net/wanrouter/wanmain.c
--- linux-2.5/net/wanrouter/wanmain.c	2003-09-22 10:21:35.000000000 -0700
+++ linux-2.5-net/net/wanrouter/wanmain.c	2003-09-22 10:49:29.000000000 -0700
@@ -726,8 +726,6 @@
 
 		if (dev->name == NULL) {
 			err = -EINVAL;
-		} else if (dev_get(dev->name)) {
-			err = -EEXIST;	/* name already exists */
 		} else {
 
 			#ifdef WANDEBUG
