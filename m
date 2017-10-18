From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/sched: Set the net-device for egress device instance
Date: Wed, 18 Oct 2017 18:38:08 +0300
Message-ID: <1508341088-20043-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35326 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751358AbdJRPiP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:38:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the netdevice field is not set and the egdev instance
is not functional, fix that.

Fixes: 3f55bdda8df ('net: sched: introduce per-egress action device callbacks')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/act_api.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index ac97db9..c67b820 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -1300,6 +1300,7 @@ tcf_action_egdev_get(const struct net_device *dev)
 	if (!egdev)
 		return NULL;
 	INIT_LIST_HEAD(&egdev->cb_list);
+	egdev->dev = dev;
 	tan = net_generic(dev_net(dev), tcf_action_net_id);
 	rhashtable_insert_fast(&tan->egdev_ht, &egdev->ht_node,
 			       tcf_action_egdev_ht_params);
-- 
2.3.7
