From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/9] ovs: use nla_put_u64_64bit()
Date: Mon, 25 Apr 2016 10:25:17 +0200
Message-ID: <1461572722-6029-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, jhs@mojatatu.com, stephen@networkplumber.org,
	pshelar@nicira.com, aar@pengutronix.de, linux-wpan@vger.kernel.org,
	wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:54435 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940AbcDYIZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 04:25:48 -0400
In-Reply-To: <1461572722-6029-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/openvswitch.h | 1 +
 net/openvswitch/datapath.c       | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 0358f94af86e..d6be1fb778a5 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -519,6 +519,7 @@ enum ovs_flow_attr {
 				  * logging should be suppressed. */
 	OVS_FLOW_ATTR_UFID,      /* Variable length unique flow identifier. */
 	OVS_FLOW_ATTR_UFID_FLAGS,/* u32 of OVS_UFID_F_*. */
+	OVS_FLOW_ATTR_PAD,
 	__OVS_FLOW_ATTR_MAX
 };
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 0cc66a4e492d..22d9a5316304 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -754,7 +754,8 @@ static int ovs_flow_cmd_fill_stats(const struct sw_flow *flow,
 	ovs_flow_stats_get(flow, &stats, &used, &tcp_flags);
 
 	if (used &&
-	    nla_put_u64(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(used)))
+	    nla_put_u64_64bit(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(used),
+			      OVS_FLOW_ATTR_PAD))
 		return -EMSGSIZE;
 
 	if (stats.n_packets &&
-- 
2.8.1
