From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH] [NETFILTER]: fix ebtable targets return
Date: Thu, 21 Feb 2008 14:36:32 +0900
Message-ID: <12035721921230-git-send-email-joonwpark81@gmail.com>
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function ebt_do_table doesn't take NF_DROP as a verdict from the targets.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 net/bridge/netfilter/ebt_dnat.c     |    2 +-
 net/bridge/netfilter/ebt_redirect.c |    2 +-
 net/bridge/netfilter/ebt_snat.c     |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index 1ec671d..ca64c1c 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -21,7 +21,7 @@ static int ebt_target_dnat(struct sk_buff *skb, unsigned int hooknr,
 	const struct ebt_nat_info *info = data;
 
 	if (!skb_make_writable(skb, 0))
-		return NF_DROP;
+		return EBT_DROP;
 
 	memcpy(eth_hdr(skb)->h_dest, info->mac, ETH_ALEN);
 	return info->target;
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index bfb9f74..b8afe85 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -22,7 +22,7 @@ static int ebt_target_redirect(struct sk_buff *skb, unsigned int hooknr,
 	const struct ebt_redirect_info *info = data;
 
 	if (!skb_make_writable(skb, 0))
-		return NF_DROP;
+		return EBT_DROP;
 
 	if (hooknr != NF_BR_BROUTING)
 		memcpy(eth_hdr(skb)->h_dest,
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index 204f996..5425333 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -23,7 +23,7 @@ static int ebt_target_snat(struct sk_buff *skb, unsigned int hooknr,
 	const struct ebt_nat_info *info = data;
 
 	if (!skb_make_writable(skb, 0))
-		return NF_DROP;
+		return EBT_DROP;
 
 	memcpy(eth_hdr(skb)->h_source, info->mac, ETH_ALEN);
 	if (!(info->target & NAT_ARP_BIT) &&
-- 
1.5.3.rc5

