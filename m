From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 32/33] netns nat: PPTP NAT in netns
Date: Mon,  8 Sep 2008 07:03:09 +0400
Message-ID: <1220842990-30500-32-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index e4bdddc..9eb1710 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -40,6 +40,7 @@ MODULE_ALIAS("ip_nat_pptp");
 static void pptp_nat_expected(struct nf_conn *ct,
 			      struct nf_conntrack_expect *exp)
 {
+	struct net *net = nf_ct_net(ct);
 	const struct nf_conn *master = ct->master;
 	struct nf_conntrack_expect *other_exp;
 	struct nf_conntrack_tuple t;
@@ -73,7 +74,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 
 	pr_debug("trying to unexpect other dir: ");
 	nf_ct_dump_tuple_ip(&t);
-	other_exp = nf_ct_expect_find_get(&init_net, &t);
+	other_exp = nf_ct_expect_find_get(net, &t);
 	if (other_exp) {
 		nf_ct_unexpect_related(other_exp);
 		nf_ct_expect_put(other_exp);
