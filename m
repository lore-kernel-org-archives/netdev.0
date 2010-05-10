From: kaber@trash.net
Subject: [PATCH 82/84] netfilter: nf_ct_h323: switch "incomplete TPKT" message to pr_debug()
Date: Mon, 10 May 2010 22:18:53 +0200
Message-ID: <1273522735-24672-83-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The message might be falsely triggered by non-H.323 traffic on port
1720.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_h323_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index a487c80..48bf150 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -194,8 +194,7 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 			return 0;
 		}
 
-		if (net_ratelimit())
-			printk("nf_ct_h323: incomplete TPKT (fragmented?)\n");
+		pr_debug("nf_ct_h323: incomplete TPKT (fragmented?)\n");
 		goto clear_out;
 	}
 
-- 
1.7.0.4

