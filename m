From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] netfilter: ctnetlink: Make some parameters integer to avoid enum mismatch
Date: Wed, 19 Apr 2017 11:39:20 -0700
Message-ID: <20170419183920.21936-1-mka@chromium.org>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Grant Grundler <grundler@chromium.org>,
        Greg Hackmann <ghackmann@google.com>,
        Michael Davidson <md@google.com>,
        Matthias Kaehlcke <mka@chromium.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all parameters passed to ctnetlink_parse_tuple() and
ctnetlink_exp_dump_tuple() match the enum type in the signatures of these
functions. Since this is intended change the argument type of to be an int
value.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 net/netfilter/nf_conntrack_netlink.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index dc7dfd68fafe..775eb5d9165b 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1006,9 +1006,8 @@ static const struct nla_policy tuple_nla_policy[CTA_TUPLE_MAX+1] = {
 
 static int
 ctnetlink_parse_tuple(const struct nlattr * const cda[],
-		      struct nf_conntrack_tuple *tuple,
-		      enum ctattr_type type, u_int8_t l3num,
-		      struct nf_conntrack_zone *zone)
+		      struct nf_conntrack_tuple *tuple, u32 type,
+		      u_int8_t l3num, struct nf_conntrack_zone *zone)
 {
 	struct nlattr *tb[CTA_TUPLE_MAX+1];
 	int err;
@@ -2443,7 +2442,7 @@ static struct nfnl_ct_hook ctnetlink_glue_hook = {
 
 static int ctnetlink_exp_dump_tuple(struct sk_buff *skb,
 				    const struct nf_conntrack_tuple *tuple,
-				    enum ctattr_expect type)
+				    u32 type)
 {
 	struct nlattr *nest_parms;
 
-- 
2.12.2.816.g2cccc81164-goog
