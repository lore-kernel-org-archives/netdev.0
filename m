From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] flow_dissector: rename "proto again" goto label
Date: Mon,  6 Mar 2017 16:39:54 +0100
Message-ID: <1488814795-5152-5-git-send-email-jiri@resnulli.us>
References: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, tom@herbertland.com,
        simon.horman@netronome.com, eric.dumazet@gmail.com,
        dinan.gunawardena@netronome.com, hadarh@mellanox.com, e@erig.me,
        fgao@ikuai8.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34941 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753208AbdCFPkE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 10:40:04 -0500
Received: by mail-wm0-f66.google.com with SMTP id z63so12193080wmg.2
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 07:40:03 -0800 (PST)
In-Reply-To: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Align with "ip_proto_again" label used in the same function and rename
vague "again" to "proto_again".

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/flow_dissector.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index cefaf23..9120835 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -267,7 +267,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		memcpy(key_eth_addrs, &eth->h_dest, sizeof(*key_eth_addrs));
 	}
 
-again:
+proto_again:
 	switch (proto) {
 	case htons(ETH_P_IP): {
 		const struct iphdr *iph;
@@ -370,7 +370,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			proto = vlan->h_vlan_encapsulated_proto;
 			nhoff += sizeof(*vlan);
 			if (skip_vlan)
-				goto again;
+				goto proto_again;
 		}
 
 		skip_vlan = true;
@@ -393,7 +393,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			}
 		}
 
-		goto again;
+		goto proto_again;
 	}
 	case htons(ETH_P_PPP_SES): {
 		struct {
@@ -577,7 +577,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
 			goto out_good;
 
-		goto again;
+		goto proto_again;
 	}
 	case NEXTHDR_HOP:
 	case NEXTHDR_ROUTING:
-- 
2.7.4
