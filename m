From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 9/9 net-next] netfilter: replace if/BUG by BUG_ON
Date: Mon, 30 Mar 2015 23:13:17 +0200
Message-ID: <1427749998-28464-9-git-send-email-fabf@skynet.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/netfilter/nfnetlink_log.c | 3 +--
 net/netfilter/xt_u32.c        | 8 +++-----
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 957b83a..409f5fb 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -577,8 +577,7 @@ __build_packet_message(struct nfnl_log_net *log,
 		nla->nla_type = NFULA_PAYLOAD;
 		nla->nla_len = size;
 
-		if (skb_copy_bits(skb, 0, nla_data(nla), data_len))
-			BUG();
+		BUG_ON(skb_copy_bits(skb, 0, nla_data(nla), data_len));
 	}
 
 	nlh->nlmsg_len = inst->skb->tail - old_tail;
diff --git a/net/netfilter/xt_u32.c b/net/netfilter/xt_u32.c
index a95b5034..5ff937d 100644
--- a/net/netfilter/xt_u32.c
+++ b/net/netfilter/xt_u32.c
@@ -38,8 +38,7 @@ static bool u32_match_it(const struct xt_u32 *data,
 		if (skb->len < 4 || pos > skb->len - 4)
 			return false;
 
-		if (skb_copy_bits(skb, pos, &n, sizeof(n)) < 0)
-			BUG();
+		BUG_ON(skb_copy_bits(skb, pos, &n, sizeof(n)) < 0);
 		val   = ntohl(n);
 		nnums = ct->nnums;
 
@@ -65,9 +64,8 @@ static bool u32_match_it(const struct xt_u32 *data,
 				    pos > skb->len - at - 4)
 					return false;
 
-				if (skb_copy_bits(skb, at + pos, &n,
-						    sizeof(n)) < 0)
-					BUG();
+				BUG_ON(skb_copy_bits(skb, at + pos, &n,
+						     sizeof(n)) < 0);
 				val = ntohl(n);
 				break;
 			}
-- 
1.9.1
