From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] netfilter: xt_TCPMSS: Fix missing fragmentation handling
Date: Mon, 17 Jun 2013 21:34:39 +0200
Message-ID: <1371497679-14314-4-git-send-email-pablo@netfilter.org>
References: <1371497679-14314-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1371497679-14314-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Oester <kernel@linuxace.com>

Similar to commit bc6bcb59 ("netfilter: xt_TCPOPTSTRIP: fix
possible mangling beyond packet boundary"), add safe fragment
handling to xt_TCPMSS.

Signed-off-by: Phil Oester <kernel@linuxace.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TCPMSS.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 6640a22..7011c71 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -57,6 +57,10 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	u16 newmss;
 	u8 *opt;
 
+	/* This is a fragment, no TCP header is available */
+	if (par->fragoff != 0)
+		return XT_CONTINUE;
+
 	if (!skb_make_writable(skb, skb->len))
 		return -1;
 
-- 
1.7.10.4

