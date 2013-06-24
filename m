From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/5] netfilter: nf_nat_sip: fix mangling
Date: Mon, 24 Jun 2013 17:15:47 +0200
Message-ID: <1372086950-4042-4-git-send-email-pablo@netfilter.org>
References: <1372086950-4042-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1372086950-4042-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balazs Peter Odor <balazs@obiserver.hu>

In (b20ab9c netfilter: nf_ct_helper: better logging for dropped packets)
there were some missing brackets around the logging information, thus
always returning drop.

Closes https://bugzilla.kernel.org/show_bug.cgi?id=60061

Signed-off-by: Balazs Peter Odor <balazs@obiserver.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_sip.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
index 96ccdf7..dac11f7 100644
--- a/net/netfilter/nf_nat_sip.c
+++ b/net/netfilter/nf_nat_sip.c
@@ -230,9 +230,10 @@ static unsigned int nf_nat_sip(struct sk_buff *skb, unsigned int protoff,
 					&ct->tuplehash[!dir].tuple.src.u3,
 					false);
 			if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
-					   poff, plen, buffer, buflen))
+					   poff, plen, buffer, buflen)) {
 				nf_ct_helper_log(skb, ct, "cannot mangle received");
 				return NF_DROP;
+			}
 		}
 
 		/* The rport= parameter (RFC 3581) contains the port number
-- 
1.7.10.4

