From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2] netfilter: ctnetlink: fix incorrect NAT expectation dumping
Date: Mon, 22 Jul 2013 10:34:36 +0200
Message-ID: <1374482077-4547-2-git-send-email-pablo@netfilter.org>
References: <1374482077-4547-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1374482077-4547-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_ct_expect_alloc leaves unset the expectation NAT fields. However,
ctnetlink_exp_dump_expect expects them to be zeroed in case they are
not used, which may not be the case. This results in dumping the NAT
tuple of the expectation when it should not.

Fix it by zeroing the NAT fields of the expectation.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index c63b618..4fd1ca9 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -293,6 +293,11 @@ void nf_ct_expect_init(struct nf_conntrack_expect *exp, unsigned int class,
 		       sizeof(exp->tuple.dst.u3) - len);
 
 	exp->tuple.dst.u.all = *dst;
+
+#ifdef CONFIG_NF_NAT_NEEDED
+	memset(&exp->saved_addr, 0, sizeof(exp->saved_addr));
+	memset(&exp->saved_proto, 0, sizeof(exp->saved_proto));
+#endif
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_init);
 
-- 
1.7.10.4

