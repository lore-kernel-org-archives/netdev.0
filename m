From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] netfilter: ipv6: fix overlap check for fragments
Date: Fri, 05 Nov 2010 19:56:40 +0800
Message-ID: <4CD3F0F8.5030205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The type of FRAG6_CB(prev)->offset is int, skb->len is *unsigned* int,
and offset is int.

Without this patch, type conversion occurred to this expression, when
(FRAG6_CB(prev)->offset + prev->len) is less than offset.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
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
1.6.3.3
