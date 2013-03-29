From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 2/6] openvswitch: Use nla_memcpy() to memcpy() data from attributes
Date: Fri, 29 Mar 2013 14:46:48 +0100
Message-ID: <1c07fc6188df608d75503ab023d798a48c389834.1364563347.git.tgraf@suug.ch>
References: <cover.1364563346.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:52009
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755944Ab3C2Nq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 09:46:59 -0400
In-Reply-To: <cover.1364563346.git.tgraf@suug.ch>
In-Reply-To: <cover.1364563346.git.tgraf@suug.ch>
References: <cover.1364563346.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Less error prone as it takes into account the length of both the
destination buffer and the source attribute and documents when
data is copied from an attribute.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c | 2 +-
 net/openvswitch/flow.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5b58d16..bca63c8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -672,7 +672,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err;
 	skb_reserve(packet, NET_IP_ALIGN);
 
-	memcpy(__skb_put(packet, len), nla_data(a[OVS_PACKET_ATTR_PACKET]), len);
+	nla_memcpy(__skb_put(packet, len), a[OVS_PACKET_ATTR_PACKET], len);
 
 	skb_reset_mac_header(packet);
 	eth = eth_hdr(packet);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 3324868..cf9328b 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -211,7 +211,7 @@ struct sw_flow_actions *ovs_flow_actions_alloc(const struct nlattr *actions)
 		return ERR_PTR(-ENOMEM);
 
 	sfa->actions_len = actions_len;
-	memcpy(sfa->actions, nla_data(actions), actions_len);
+	nla_memcpy(sfa->actions, actions, actions_len);
 	return sfa;
 }
 
-- 
1.7.11.7
