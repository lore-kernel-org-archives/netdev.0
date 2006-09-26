From: Thomas Graf <tgraf@suug.ch>
Subject: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Tue, 26 Sep 2006 13:59:10 +0200
Message-ID: <20060926115910.GV18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kim.nordlund@nokia.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:48050 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751178AbWIZL6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 07:58:49 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prevents filters from being added if the first generated
handle already exists.

Signed-off-by: Kim Nordlund <kim.nordlund@nokia.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/sched/cls_basic.c
===================================================================
--- net-2.6.orig/net/sched/cls_basic.c	2006-09-26 13:35:29.000000000 +0200
+++ net-2.6/net/sched/cls_basic.c	2006-09-26 13:35:39.000000000 +0200
@@ -194,7 +194,7 @@
 	if (handle)
 		f->handle = handle;
 	else {
-		int i = 0x80000000;
+		unsigned int i = 0x80000000;
 		do {
 			if (++head->hgenerator == 0x7FFFFFFF)
 				head->hgenerator = 1;
