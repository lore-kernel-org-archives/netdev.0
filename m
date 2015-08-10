From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/5] netfilter: conntrack: Use flags in nf_ct_tmpl_alloc()
Date: Mon, 10 Aug 2015 19:58:37 +0200
Message-ID: <1439229519-7640-4-git-send-email-pablo@netfilter.org>
References: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>

The flags were ignored for this function when it was introduced. Also
fix the style problem in kzalloc.

Fixes: 0838aa7fc (netfilter: fix netns dependencies with conntrack
templates)
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f168099..3c20d02 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -292,7 +292,7 @@ struct nf_conn *nf_ct_tmpl_alloc(struct net *net, u16 zone, gfp_t flags)
 {
 	struct nf_conn *tmpl;
 
-	tmpl = kzalloc(sizeof(struct nf_conn), GFP_KERNEL);
+	tmpl = kzalloc(sizeof(*tmpl), flags);
 	if (tmpl == NULL)
 		return NULL;
 
@@ -303,7 +303,7 @@ struct nf_conn *nf_ct_tmpl_alloc(struct net *net, u16 zone, gfp_t flags)
 	if (zone) {
 		struct nf_conntrack_zone *nf_ct_zone;
 
-		nf_ct_zone = nf_ct_ext_add(tmpl, NF_CT_EXT_ZONE, GFP_ATOMIC);
+		nf_ct_zone = nf_ct_ext_add(tmpl, NF_CT_EXT_ZONE, flags);
 		if (!nf_ct_zone)
 			goto out_free;
 		nf_ct_zone->id = zone;
-- 
1.7.10.4

