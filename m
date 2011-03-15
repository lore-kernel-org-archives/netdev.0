From: kaber@trash.net
Subject: [PATCH 08/37] IPVS: Fix variable assignment in ip_vs_notrack
Date: Tue, 15 Mar 2011 20:43:48 +0100
Message-ID: <1300218257-26953-9-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>

There's no sense to 'ct = ct = ' in ip_vs_notrack(). Just assign
nf_ct_get()'s return value directly to the pointer variable 'ct' once.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e74da41e..1dcb75d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1190,7 +1190,7 @@ static inline void ip_vs_notrack(struct sk_buff *skb)
 {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 	if (!ct || !nf_ct_is_untracked(ct)) {
 		nf_reset(skb);
-- 
1.7.2.3

