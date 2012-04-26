From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net 3/3] 6lowpan: add missing spin_lock_init()
Date: Thu, 26 Apr 2012 13:24:58 +0400
Message-ID: <1335432298-17161-4-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1335432298-17161-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:58666 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753Ab2DZJbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:31:11 -0400
Received: by wgbds11 with SMTP id ds11so5213235wgb.1
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 02:31:09 -0700 (PDT)
In-Reply-To: <1335432298-17161-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing spin_lock_init() for frames list lock.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index a21ca6e..b570dbf 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1168,6 +1168,8 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 	list_add_tail(&entry->list, &lowpan_devices);
 	mutex_unlock(&lowpan_dev_info(dev)->dev_list_mtx);
 
+	spin_lock_init(&flist_lock);
+
 	register_netdevice(dev);
 
 	return 0;
-- 
1.7.2.3
