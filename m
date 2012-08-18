From: Cong Wang <amwang@redhat.com>
Subject: [Patch] netconsole: remove a redundant netconsole_target_put()
Date: Sun, 19 Aug 2012 01:02:20 +0800
Message-ID: <1345309340-15499-1-git-send-email-amwang@redhat.com>
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751817Ab2HRRCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Aug 2012 13:02:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This netconsole_target_put() is obviously redundant, and it
causes a kernel segfault when removing a bridge device which has
netconsole running on it.

This is caused by:

	commit 8d8fc29d02a33e4bd5f4fa47823c1fd386346093
	Author: Amerigo Wang <amwang@redhat.com>
	Date:   Thu May 19 21:39:10 2011 +0000

	    netpoll: disable netpoll when enslave a device

Cc: David Miller <davem@davemloft.net>
 (for all 3.x stable releases)
Cc: stable@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index f0ad56c..b332112 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -643,7 +643,6 @@ static int netconsole_netdev_event(struct notifier_block *this,
 					__netpoll_cleanup(&nt->np);
 					dev_put(nt->np.dev);
 					nt->np.dev = NULL;
-					netconsole_target_put(nt);
 				}
 				nt->enabled = 0;
 				stopped = true;
