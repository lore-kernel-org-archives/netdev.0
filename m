From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/8] netfilter: WARN about wrong usage of sequence number adjustments
Date: Sat, 28 Dec 2013 23:03:03 +0100
Message-ID: <1388268187-11569-5-git-send-email-pablo@netfilter.org>
References: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43863 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433Ab3L1WD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Dec 2013 17:03:26 -0500
In-Reply-To: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>

Since commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence
number adjustments usuable without NAT), the sequence number extension
is dynamically allocated.

Instead of dying, give a WARN splash, in case of wrong usage of the
seqadj code, e.g. when forgetting to allocate via nfct_seqadj_ext_add().

Wrong usage have been seen in the IPVS code path.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/nf_conntrack_seqadj.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index 17c1bcb..b2d38da 100644
--- a/net/netfilter/nf_conntrack_seqadj.c
+++ b/net/netfilter/nf_conntrack_seqadj.c
@@ -36,6 +36,11 @@ int nf_ct_seqadj_set(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 	if (off == 0)
 		return 0;
 
+	if (unlikely(!seqadj)) {
+		WARN(1, "Wrong seqadj usage, missing nfct_seqadj_ext_add()\n");
+		return 0;
+	}
+
 	set_bit(IPS_SEQ_ADJUST_BIT, &ct->status);
 
 	spin_lock_bh(&ct->lock);
-- 
1.7.10.4
