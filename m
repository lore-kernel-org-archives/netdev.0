From: Bill Moss <bmoss@CLEMSON.EDU>
Subject: [PATCH 2.6.13] airo.c: remove delay in airo_get_scan
Date: Tue, 1 Nov 2005 22:47:57 -0500
Message-ID: <200511020347.jA23lvi9028538@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932260AbVKBDs1@vger.kernel.org>
To: linville@tuxdriver.com, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove 3 second delay in airo_get_scan. Testing shows this delay is unnecessary. Users of NetworkManager
find this delay make NetworkManager slow to connect.

--- a/drivers/net/wireless/airo.c	2005-11-01 21:21:04.000000000 -0500
+++ b/drivers/net/wireless/airo.c	2005-11-01 21:22:41.000000000 -0500
@@ -6918,7 +6918,7 @@
 	/* When we are associated again, the scan has surely finished.
 	 * Just in case, let's make sure enough time has elapsed since
 	 * we started the scan. - Javier */
-	if(ai->scan_timestamp && time_before(jiffies,ai->scan_timestamp+3*HZ)) {
+	if(ai->scan_timestamp && time_before(jiffies,ai->scan_timestamp)) {
 		/* Important note : we don't want to block the caller
 		 * until results are ready for various reasons.
 		 * First, managing wait queues is complex and racy

Signed-off-by: Bill Moss <bmoss@clemson.edu>
