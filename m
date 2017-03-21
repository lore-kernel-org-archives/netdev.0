From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 2/5] netfilter: Clean up tests if NULL returned on failure
Date: Tue, 21 Mar 2017 14:14:36 +0530
Message-ID: <1490085879-1827-3-git-send-email-singhalsimran0@gmail.com>
References: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490085879-1827-1-git-send-email-singhalsimran0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some functions like kmalloc/kzalloc return NULL on failure. When NULL
represents failure, !x is commonly used.

This was done using Coccinelle:
@@
expression *e;
identifier l1;
@@
e = \(kmalloc\|kzalloc\|kcalloc\|devm_kzalloc\)(...);
...
- e == NULL
+ !e

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---

 --This is my contribution to the netfilter project of
   Outreachy Round 14.

 net/netfilter/nf_conntrack_netlink.c | 2 +-
 net/netfilter/nf_conntrack_proto.c   | 2 +-
 net/netfilter/nf_nat_core.c          | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6806b5e..cdcf4c1 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -779,7 +779,7 @@ ctnetlink_alloc_filter(const struct nlattr * const cda[])
 	struct ctnetlink_filter *filter;
 
 	filter = kzalloc(sizeof(*filter), GFP_KERNEL);
-	if (filter == NULL)
+	if (!filter)
 		return ERR_PTR(-ENOMEM);
 
 	filter->mark.val = ntohl(nla_get_be32(cda[CTA_MARK]));
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 2d6ee18..48d8354 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -358,7 +358,7 @@ int nf_ct_l4proto_register_one(struct nf_conntrack_l4proto *l4proto)
 		proto_array = kmalloc(MAX_NF_CT_PROTO *
 				      sizeof(struct nf_conntrack_l4proto *),
 				      GFP_KERNEL);
-		if (proto_array == NULL) {
+		if (!proto_array) {
 			ret = -ENOMEM;
 			goto out_unlock;
 		}
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 94b14c5..922bd5b 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -626,7 +626,7 @@ int nf_nat_l4proto_register(u8 l3proto, const struct nf_nat_l4proto *l4proto)
 	if (nf_nat_l4protos[l3proto] == NULL) {
 		l4protos = kmalloc(IPPROTO_MAX * sizeof(struct nf_nat_l4proto *),
 				   GFP_KERNEL);
-		if (l4protos == NULL) {
+		if (!l4protos) {
 			ret = -ENOMEM;
 			goto out;
 		}
-- 
2.7.4
