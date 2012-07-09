From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next 1/6] 6lowpan: revert: add missing spin_lock_init()
Date: Mon,  9 Jul 2012 14:22:26 +0400
Message-ID: <1341829351-18485-2-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33420 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998Ab2GIK0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 06:26:36 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so5787740bkw.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 03:26:35 -0700 (PDT)
In-Reply-To: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Revert the commit 768f7c7c121e80f458a9d013b2e8b169e5dfb1e5 to initialize
spinlock in the more preferable way and make it static to avoid sparse
warning.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index f4070e5..b872515 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -123,7 +123,7 @@ struct lowpan_fragment {
 
 static unsigned short fragment_tag;
 static LIST_HEAD(lowpan_fragments);
-spinlock_t flist_lock;
+static DEFINE_SPINLOCK(flist_lock);
 
 static inline struct
 lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
@@ -1186,8 +1186,6 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 	list_add_tail(&entry->list, &lowpan_devices);
 	mutex_unlock(&lowpan_dev_info(dev)->dev_list_mtx);
 
-	spin_lock_init(&flist_lock);
-
 	register_netdevice(dev);
 
 	return 0;
-- 
1.7.2.3
