From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] netpoll: prevent netpoll setup on slave devices
Date: Thu,  9 Jun 2011 10:42:40 +0800
Message-ID: <1307587360-3092-1-git-send-email-amwang@redhat.com>
Cc: WANG Cong <amwang@redhat.com>, Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58757 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241Ab1FICmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 22:42:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 8d8fc29d02a33e4bd5f4fa47823c1fd386346093
(netpoll: disable netpoll when enslave a device), we automatically
disable netpoll when the underlying device is being enslaved,
we also need to prevent people from setuping netpoll on
devices that are already enslaved.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>

---
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 2d7d6d4..42ea4b0 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -792,6 +792,12 @@ int netpoll_setup(struct netpoll *np)
 		return -ENODEV;
 	}
 
+	if (ndev->master) {
+		printk(KERN_ERR "%s: %s is a slave device, aborting.\n",
+		       np->name, np->dev_name);
+		return -EBUSY;
+	}
+
 	if (!netif_running(ndev)) {
 		unsigned long atmost, atleast;
 
