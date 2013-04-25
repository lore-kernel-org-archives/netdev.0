From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/10] ipvs: Use min3() in ip_vs_dbg_callid()
Date: Thu, 25 Apr 2013 02:22:18 +0200
Message-ID: <1366849341-10466-8-git-send-email-pablo@netfilter.org>
References: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

There are two motivations for this:

1. It improves readability to my eyes
2. Using nested min() calls results in a shadowed _min1 variable,
   which is a bit untidy. Sparse complained about this.

I have also replaced (size_t)64 with a variable of type size_t and value 64.
This also improves readability to my eyes.

Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 00cc024..9a8f421 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -13,7 +13,8 @@ static const char *ip_vs_dbg_callid(char *buf, size_t buf_len,
 				    const char *callid, size_t callid_len,
 				    int *idx)
 {
-	size_t len = min(min(callid_len, (size_t)64), buf_len - *idx - 1);
+	size_t max_len = 64;
+	size_t len = min3(max_len, callid_len, buf_len - *idx - 1);
 	memcpy(buf + *idx, callid, len);
 	buf[*idx+len] = '\0';
 	*idx += len + 1;
-- 
1.7.10.4

