From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/53] netfilter: ipvs: don't check for presence of nat extension
Date: Mon,  1 May 2017 12:46:28 +0200
Message-ID: <1493635640-24325-2-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Check for the NAT status bits, they are set once conntrack needs NAT in source or
reply direction, this is slightly faster than nfct_nat() as that has to check the
extension area.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/ipvs/ip_vs_ftp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d30c327bb578..2e2bf7428cd1 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -260,7 +260,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		buf_len = strlen(buf);
 
 		ct = nf_ct_get(skb, &ctinfo);
-		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
+		if (ct && !nf_ct_is_untracked(ct) && (ct->status & IPS_NAT_MASK)) {
 			/* If mangling fails this function will return 0
 			 * which will cause the packet to be dropped.
 			 * Mangling can only fail under memory pressure,
-- 
2.1.4

