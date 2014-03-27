From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] dev: ensure that dellink is set before calling it
Date: Thu, 27 Mar 2014 14:11:02 +0100
Message-ID: <1395925862-19354-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41806 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591AbaC0NLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 09:11:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

default_device_exit_batch() was calling it as soon as dev->rtnl_link_ops was
set.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

I target this patch to net-next because I did not found an in-tree driver
which is impacted.

 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 48dd323d5918..f4010d16b351 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6940,7 +6940,7 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
 	rtnl_lock_unregistering(net_list);
 	list_for_each_entry(net, net_list, exit_list) {
 		for_each_netdev_reverse(net, dev) {
-			if (dev->rtnl_link_ops)
+			if (dev->rtnl_link_ops && dev->rtnl_link_ops->dellink)
 				dev->rtnl_link_ops->dellink(dev, &dev_kill_list);
 			else
 				unregister_netdevice_queue(dev, &dev_kill_list);
-- 
1.8.5.4
