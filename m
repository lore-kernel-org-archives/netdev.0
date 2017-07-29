From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/2] decnet: dn_rtmsg: constify nf_hook_ops structures
Date: Sat, 29 Jul 2017 08:40:53 +0200
Message-ID: <1501310455-7896-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1501310455-7896-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: bhumirks@gmail.com, kernel-janitors@vger.kernel.org,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501310455-7896-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nf_hook_ops structure is only passed as the second argument to
nf_register_net_hook or nf_unregister_net_hook, both of which are
declared as const.  Thus the nf_hook_ops structure itself can be
const.

Done with the help of Coccinelle.

// <smpl>
@r disable optional_qualifier@
identifier i;
position p;
@@
static struct nf_hook_ops i@p = { ... };

@ok1@
identifier r.i;
expression e;
position p;
@@
 \(nf_register_net_hook\|nf_unregister_net_hook\)(e,&i@p)

@bad@
position p != {r.p,ok1.p};
identifier r.i;
struct nf_hook_ops e;
@@
e@i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
static
+const
 struct nf_hook_ops i = { ... };
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/decnet/netfilter/dn_rtmsg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index aa8ffec..ab395e5 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -115,7 +115,7 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 	RCV_SKB_FAIL(-EINVAL);
 }
 
-static struct nf_hook_ops dnrmg_ops __read_mostly = {
+static const struct nf_hook_ops dnrmg_ops = {
 	.hook		= dnrmg_hook,
 	.pf		= NFPROTO_DECNET,
 	.hooknum	= NF_DN_ROUTE,
