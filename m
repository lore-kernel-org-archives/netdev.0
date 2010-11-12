From: kaber@trash.net
Subject: [PATCH 2/2] netfilter: ipv6: fix overlap check for fragments
Date: Fri, 12 Nov 2010 16:19:32 +0100
Message-ID: <1289575172-7272-3-git-send-email-kaber@trash.net>
References: <1289575172-7272-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Shan Wei <shanwei@cn.fujitsu.com>,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289575172-7272-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <shanwei@cn.fujitsu.com>

The type of FRAG6_CB(prev)->offset is int, skb->len is *unsigned* int,
and offset is int.

Without this patch, type conversion occurred to this expression, when
(FRAG6_CB(prev)->offset + prev->len) is less than offset.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 3a3f129..79d43aa 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -286,7 +286,7 @@ found:
 
 	/* Check for overlap with preceding fragment. */
 	if (prev &&
-	    (NFCT_FRAG6_CB(prev)->offset + prev->len) - offset > 0)
+	    (NFCT_FRAG6_CB(prev)->offset + prev->len) > offset)
 		goto discard_fq;
 
 	/* Look for overlap with succeeding segment. */
-- 
1.7.3.2

