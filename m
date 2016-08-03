From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v2] netfilter: nf_conntrack_sip: CSeq 0 is a valid CSeq
Date: Wed,  3 Aug 2016 12:41:40 +0200 (CEST)
Message-ID: <20160803104141.12CDB1A2394@localhost.localdomain>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not drop packet when CSeq is 0 as 0 is also a valid value for CSeq.

simple_strtoul() will return 0 either when all digits are 0
or if there are no digits at all. Therefore when simple_strtoul()
returns 0 we check if first character is digit 0 or not.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 v2: not using kstrtouint() anymore, as it required to use a temp buffer

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
2.1.0
