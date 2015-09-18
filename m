From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 10/15] act_connmark: Remember the struct net instead of guessing it.
Date: Fri, 18 Sep 2015 14:33:03 -0500
Message-ID: <1442604788-19718-10-git-send-email-ebiederm@xmission.com>
References: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stop guessing the struct net instead of remember it.  Guessing is just
silly and will be problematic in the future when I implement routes
between network namespaces.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/tc_act/tc_connmark.h | 1 +
 net/sched/act_connmark.c         | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/tc_act/tc_connmark.h b/include/net/tc_act/tc_connmark.h
index 5c1104c2e24f..02caa406611b 100644
--- a/include/net/tc_act/tc_connmark.h
+++ b/include/net/tc_act/tc_connmark.h
@@ -5,6 +5,7 @@
 
 struct tcf_connmark_info {
 	struct tcf_common common;
+	struct net *net;
 	u16 zone;
 };
 
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 5019a47b9270..413ac39147d8 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -74,7 +74,7 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 	zone.id = ca->zone;
 	zone.dir = NF_CT_DEFAULT_ZONE_DIR;
 
-	thash = nf_conntrack_find_get(dev_net(skb->dev), &zone, &tuple);
+	thash = nf_conntrack_find_get(ca->net, &zone, &tuple);
 	if (!thash)
 		goto out;
 
@@ -119,6 +119,7 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 
 		ci = to_connmark(a);
 		ci->tcf_action = parm->action;
+		ci->net = net;
 		ci->zone = parm->zone;
 
 		tcf_hash_insert(a);
-- 
2.2.1

