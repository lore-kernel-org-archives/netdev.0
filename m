From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 22/22] xfrm offload v2: Add some documentation for the IPSEC crypto offload
Date: Mon, 10 Jan 2005 10:37:03 -0500
Message-ID: <20040110014300.31@ori.thedillows.org>
References: <20040110014300.30@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 01:09:16-05:00 dave@thedillows.org 
#   Add some documentation for the IPSEC crypto offload.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# Documentation/networking/netdevices.txt
#   2005/01/10 01:09:00-05:00 dave@thedillows.org +16 -0
#   Add some documentation for the IPSEC crypto offload.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
--- a/Documentation/networking/netdevices.txt	2005-01-10 01:16:18 -05:00
+++ b/Documentation/networking/netdevices.txt	2005-01-10 01:16:18 -05:00
@@ -73,3 +73,19 @@
 		dev_close code and comments in net/core/dev.c for more info.
 	Context: softirq
 
+dev->xfrm_state_add:
+	Synchronization: rtnl_lock() semaphore.
+	Context: process
+	Notes: Only called for inbound xfrm_state(s). Can be invoked during
+       		xfrm_accel_add() call.
+
+dev->xfrm_state_del:
+	Synchronization: None, but can be called inside dev->xmit_lock spinlock.
+	Context: BHs disabled/softirq
+	Notes: Called for all offloaded xfrm_state(s). Can be invoked during
+		xfrm_accel_flush() call. And possibly after dev->close...
+
+dev->xfrm_bundle_add:
+	Synchronization: None
+	Context: process
+	Notes: Called for newly created outbound xfrm bundles.
