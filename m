From: kaber@trash.net
Subject: [PATCH 7/8] netfilter: nf_ct_tcp: wrong multiplication of TCPOLEN_TSTAMP_ALIGNED in tcp_sack skips fastpath
Date: Tue, 30 Aug 2011 16:41:20 +0200
Message-ID: <1314715281-26233-8-git-send-email-kaber@trash.net>
References: <1314715281-26233-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1314715281-26233-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The wrong multiplication of TCPOLEN_TSTAMP_ALIGNED by 4 skips the fast path
for the timestamp-only option. Bug reported by Michael M. Builov (netfilter
bugzilla #738).

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index afc4ab7..8235b86 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -447,7 +447,7 @@ static void tcp_sack(const struct sk_buff *skb, unsigned int dataoff,
 	BUG_ON(ptr == NULL);
 
 	/* Fast path for timestamp-only option */
-	if (length == TCPOLEN_TSTAMP_ALIGNED*4
+	if (length == TCPOLEN_TSTAMP_ALIGNED
 	    && *(__be32 *)ptr == htonl((TCPOPT_NOP << 24)
 				       | (TCPOPT_NOP << 16)
 				       | (TCPOPT_TIMESTAMP << 8)
-- 
1.7.2.3

