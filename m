From: roy.qing.li@gmail.com
Subject: [PATCH] ipv4: remove useless codes in ipmr_device_event()
Date: Thu, 24 Nov 2011 17:10:52 +0800
Message-ID: <1322125852-15395-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:53790 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753949Ab1KXJLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 04:11:09 -0500
Received: by iage36 with SMTP id e36so2731839iag.19
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 01:11:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

Commit 7dc00c82 added a 'notify' parameter for vif_delete() to
distinguish whether to unregister the device.

When notify=1 means we does not need to unregister the device,
so calling unregister_netdevice_many is useless.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv4/ipmr.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 76a7f07..8e54490 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1520,7 +1520,6 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 	struct mr_table *mrt;
 	struct vif_device *v;
 	int ct;
-	LIST_HEAD(list);
 
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
@@ -1529,10 +1528,9 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 		v = &mrt->vif_table[0];
 		for (ct = 0; ct < mrt->maxvif; ct++, v++) {
 			if (v->dev == dev)
-				vif_delete(mrt, ct, 1, &list);
+				vif_delete(mrt, ct, 1, NULL);
 		}
 	}
-	unregister_netdevice_many(&list);
 	return NOTIFY_DONE;
 }
 
-- 
1.7.1
