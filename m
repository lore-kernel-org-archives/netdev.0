From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/9] netfilter: nf_conntrack_sip: CSeq 0 is a valid CSeq
Date: Wed, 10 Aug 2016 21:16:40 +0200
Message-ID: <1470856605-7903-5-git-send-email-pablo@netfilter.org>
References: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>

Do not drop packet when CSeq is 0 as 0 is also a valid value for CSeq.

simple_strtoul() will return 0 either when all digits are 0
or if there are no digits at all. Therefore when simple_strtoul()
returns 0 we check if first character is digit 0 or not.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_sip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 8d9db9d..7d77217 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1383,7 +1383,7 @@ static int process_sip_response(struct sk_buff *skb, unsigned int protoff,
 		return NF_DROP;
 	}
 	cseq = simple_strtoul(*dptr + matchoff, NULL, 10);
-	if (!cseq) {
+	if (!cseq && *(*dptr + matchoff) != '0') {
 		nf_ct_helper_log(skb, ct, "cannot get cseq");
 		return NF_DROP;
 	}
@@ -1446,7 +1446,7 @@ static int process_sip_request(struct sk_buff *skb, unsigned int protoff,
 			return NF_DROP;
 		}
 		cseq = simple_strtoul(*dptr + matchoff, NULL, 10);
-		if (!cseq) {
+		if (!cseq && *(*dptr + matchoff) != '0') {
 			nf_ct_helper_log(skb, ct, "cannot get cseq");
 			return NF_DROP;
 		}
-- 
2.1.4

