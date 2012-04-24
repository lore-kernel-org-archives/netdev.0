From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 5/5] 6lowpan: add missing spin_lock_init()
Date: Tue, 24 Apr 2012 14:51:11 +0400
Message-ID: <1335264671-27127-6-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1335264671-27127-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55776 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995Ab2DXKvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 06:51:43 -0400
Received: by mail-bk0-f46.google.com with SMTP id w12so313874bku.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 03:51:42 -0700 (PDT)
In-Reply-To: <1335264671-27127-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing spin_lock_init() for frames list lock.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 8c1d212..32eb417 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1183,6 +1183,8 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 	list_add_tail(&entry->list, &lowpan_devices);
 	mutex_unlock(&lowpan_dev_info(dev)->dev_list_mtx);
 
+	spin_lock_init(&flist_lock);
+
 	register_netdevice(dev);
 
 	return 0;
-- 
1.7.2.3
