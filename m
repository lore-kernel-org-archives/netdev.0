From: Calvin Owens <calvinowens@fb.com>
Subject: [PATCH net-next] nfnetlink_log: Use GFP_NOWARN for skb allocation
Date: Fri, 7 Oct 2016 14:02:16 -0700
Message-ID: <1b50152e3ea7c3e18995349126d4352e4fc73933.1475873569.git.calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netfilter-devel@vger.kernel.org>, <coreteam@netfilter.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-team@fb.com>, Calvin Owens <calvinowens@fb.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the code explicilty falls back to a smaller allocation when the
large one fails, we shouldn't complain when that happens.

Signed-off-by: Calvin Owens <calvinowens@fb.com>
---
 net/netfilter/nfnetlink_log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index eb086a1..7435505 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -330,7 +330,7 @@ nfulnl_alloc_skb(struct net *net, u32 peer_portid, unsigned int inst_size,
 	 * message.  WARNING: has to be <= 128k due to slab restrictions */
 
 	n = max(inst_size, pkt_size);
-	skb = alloc_skb(n, GFP_ATOMIC);
+	skb = alloc_skb(n, GFP_ATOMIC | __GFP_NOWARN);
 	if (!skb) {
 		if (n > pkt_size) {
 			/* try to allocate only as much as we need for current
-- 
2.9.3

