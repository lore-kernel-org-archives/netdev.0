From: Dan Carpenter <error27@gmail.com>
Subject: [patch 2/3 -next] 6LoWPAN: use the _safe version of list_for_each
Date: Tue, 30 Aug 2011 16:46:40 +0300
Message-ID: <20110830134640.GI3705@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>,
	"David S. Miller" <davem@davemloft.net>,
	"open list:IEEE 802.15.4 SUB..."
	<linux-zigbee-devel@lists.sourceforge.net>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:46529 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109Ab1H3NtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 09:49:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we kfree(entry) that causes a use-after-free bug so we have to
use list_for_each_entry_safe() safe here.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
Curly parens are not needed here, but kernel style is to use them for
multi-line indent blocks.

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index cf304cc..5dc0489 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -813,15 +813,17 @@ static void lowpan_dellink(struct net_device *dev, struct list_head *head)
 	struct lowpan_dev_info *lowpan_dev = lowpan_dev_info(dev);
 	struct net_device *real_dev = lowpan_dev->real_dev;
 	struct lowpan_dev_record *entry;
+	struct lowpan_dev_record *tmp;
 
 	ASSERT_RTNL();
 
 	mutex_lock(&lowpan_dev_info(dev)->dev_list_mtx);
-	list_for_each_entry(entry, &lowpan_devices, list)
+	list_for_each_entry_safe(entry, tmp, &lowpan_devices, list) {
 		if (entry->ldev == dev) {
 			list_del(&entry->list);
 			kfree(entry);
 		}
+	}
 	mutex_unlock(&lowpan_dev_info(dev)->dev_list_mtx);
 
 	mutex_destroy(&lowpan_dev_info(dev)->dev_list_mtx);
