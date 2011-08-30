From: Dan Carpenter <error27@gmail.com>
Subject: [patch 3/3 -next] 6LoWPAN: call dev_put() on error in
 lowpan_newlink()
Date: Tue, 30 Aug 2011 16:51:09 +0300
Message-ID: <20110830135109.GJ3705@shale.localdomain>
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
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57023 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753069Ab1H3Nxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 09:53:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should release the dev_hold() on error before returning here.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
All three of these patches were compile tested only, but this is the
one I'm not very certain of.  I've obviously tried to get it right,
but please review it carefully.

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 5dc0489..f0d1536 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -793,8 +793,11 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 	mutex_init(&lowpan_dev_info(dev)->dev_list_mtx);
 
 	entry = kzalloc(sizeof(struct lowpan_dev_record), GFP_KERNEL);
-	if (!entry)
+	if (!entry) {
+		dev_put(real_dev);
+		lowpan_dev_info(dev)->real_dev = NULL;
 		return -ENOMEM;
+	}
 
 	entry->ldev = dev;
 
