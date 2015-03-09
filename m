From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/12] netfilter: ipt_CLUSTERIP: deprecate it in favour of xt_cluster
Date: Mon,  9 Mar 2015 18:14:26 +0100
Message-ID: <1425921275-9171-4-git-send-email-pablo@netfilter.org>
References: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

xt_cluster supersedes ipt_CLUSTERIP since it can be also used in
gateway configurations (not only from the backend side).

ipt_CLUSTER is also known to leak the netdev that it uses on
device removal, which requires a rather large fix to workaround
the problem: http://patchwork.ozlabs.org/patch/358629/

So let's deprecate this so we can probably kill code this in the
future.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/x_tables.h       |    1 +
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
index c24060e..4d6597a 100644
--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -9,6 +9,7 @@ struct ebt_table;
 struct netns_xt {
 	struct list_head tables[NFPROTO_NUMPROTO];
 	bool notrack_deprecated_warning;
+	bool clusterip_deprecated_warning;
 #if defined(CONFIG_BRIDGE_NF_EBTABLES) || \
     defined(CONFIG_BRIDGE_NF_EBTABLES_MODULE)
 	struct ebt_table *broute_table;
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index e90f83a..f75e9df 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -418,6 +418,13 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
+
+	if (!par->net->xt.clusterip_deprecated_warning) {
+		pr_info("ipt_CLUSTERIP is deprecated and it will removed soon, "
+			"use xt_cluster instead\n");
+		par->net->xt.clusterip_deprecated_warning = true;
+	}
+
 	return ret;
 }
 
-- 
1.7.10.4

