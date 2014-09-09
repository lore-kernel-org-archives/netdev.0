From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 1/7] cxgb4: remove bond->lock
Date: Tue,  9 Sep 2014 23:16:57 +0200
Message-ID: <1410297423-26624-2-git-send-email-nikolay@redhat.com>
References: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Cc: hariprasad@chelsio.com, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751176AbaIIVRQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 17:17:16 -0400
In-Reply-To: <1410297423-26624-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTNL should be already held in the notifier call so the slave list can
be traversed without a problem, remove the unnecessary bond->lock.

CC: Hariprasad S <hariprasad@chelsio.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: new patch

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 18fb9c61d7ba..fb5f57fdb423 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4386,7 +4386,6 @@ static int cxgb4_inet6addr_handler(struct notifier_block *this,
 		 * bond. We need to find such different adapters and add clip
 		 * in all of them only once.
 		 */
-		read_lock(&bond->lock);
 		bond_for_each_slave(bond, slave, iter) {
 			if (!first_pdev) {
 				ret = clip_add(slave->dev, ifa, event);
@@ -4400,7 +4399,6 @@ static int cxgb4_inet6addr_handler(struct notifier_block *this,
 				   to_pci_dev(slave->dev->dev.parent))
 					ret = clip_add(slave->dev, ifa, event);
 		}
-		read_unlock(&bond->lock);
 	} else
 		ret = clip_add(ifa->idev->dev, ifa, event);
 
-- 
1.9.3
