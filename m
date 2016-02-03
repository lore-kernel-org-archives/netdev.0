From: Joe Stringer <joe@ovn.org>
Subject: [PATCH nf-next] netfilter: nf_defrag_ipv4: Drop redundant ip_send_check()
Date: Wed,  3 Feb 2016 10:00:10 -0800
Message-ID: <1454522410-24976-1-git-send-email-joe@ovn.org>
Cc: Joe Stringer <joe@ovn.org>, linux-kernel@vger.kernel.org,
	pablo@netfilter.org, edjee@google.com, edumazet@google.com
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 0848f6428ba3 ("inet: frags: fix defragmented packet's IP
header for af_packet"), ip_send_check() would be called twice for
defragmentation that occurs from netfilter ipv4 defrag hooks. Remove the
extra call.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
 net/ipv4/netfilter/nf_defrag_ipv4.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 6fb869f646bf..47a541578aeb 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -33,10 +33,8 @@ static int nf_ct_ipv4_gather_frags(struct net *net, struct sk_buff *skb,
 	err = ip_defrag(net, skb, user);
 	local_bh_enable();
 
-	if (!err) {
-		ip_send_check(ip_hdr(skb));
+	if (!err)
 		skb->ignore_df = 1;
-	}
 
 	return err;
 }
-- 
2.1.4
