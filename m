From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 03/13] net/sched: cls_flower: Allow setting encapsulation fields as used key
Date: Mon,  7 Nov 2016 15:14:38 +0200
Message-ID: <1478524488-1377-4-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39577 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753294AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

When encapsulation field is set, mark it as used key for the flow
dissector. This will be used by offloading drivers.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 net/sched/cls_flower.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index db4cd88..6369b74 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -567,6 +567,16 @@ static void fl_init_dissector(struct cls_fl_head *head,
 			     FLOW_DISSECTOR_KEY_PORTS, tp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_VLAN, vlan);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ENC_KEYID, enc_key_id);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS, enc_ipv4);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS, enc_ipv6);
+	if (FL_KEY_IS_MASKED(&mask->key, enc_ipv4) ||
+	    FL_KEY_IS_MASKED(&mask->key, enc_ipv6))
+		FL_KEY_SET(keys, cnt, FLOW_DISSECTOR_KEY_ENC_CONTROL,
+			   enc_control);
 
 	skb_flow_dissector_init(&head->dissector, keys, cnt);
 }
-- 
2.7.4
