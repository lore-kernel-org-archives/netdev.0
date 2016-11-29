From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] openvswitch: add sanity check in queue_userspace_packet.
Date: Tue, 29 Nov 2016 12:36:36 +0800
Message-ID: <1480394196-73882-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: Pravin Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:19748 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752250AbcK2Egt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 23:36:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kernel will crash in oops if genlmsg_put return NULL,
so add the sanity check.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/openvswitch/datapath.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 2d4c4d3..ceb1b1e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -474,6 +474,10 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 
 	upcall = genlmsg_put(user_skb, 0, 0, &dp_packet_genl_family,
 			     0, upcall_info->cmd);
+	if (!upcall) {
+		err = -EMSGSIZE;
+		goto out;
+	}
 	upcall->dp_ifindex = dp_ifindex;
 
 	err = ovs_nla_put_key(key, key, OVS_PACKET_ATTR_KEY, false, user_skb);
-- 
1.8.3.1
