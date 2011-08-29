From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/24] decnet: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:28 -0700
Message-ID: <d8d25441690f07e551ebf886a6990312918c9e95.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/decnet/dn_neigh.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 7f0eb08..0889870 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -230,8 +230,6 @@ static int dn_long_output(struct neighbour *neigh, struct sk_buff *skb)
 	if (skb_headroom(skb) < headroom) {
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, headroom);
 		if (skb2 == NULL) {
-			if (net_ratelimit())
-				printk(KERN_CRIT "dn_long_output: no memory\n");
 			kfree_skb(skb);
 			return -ENOBUFS;
 		}
@@ -275,8 +273,6 @@ static int dn_short_output(struct neighbour *neigh, struct sk_buff *skb)
 	if (skb_headroom(skb) < headroom) {
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, headroom);
 		if (skb2 == NULL) {
-			if (net_ratelimit())
-				printk(KERN_CRIT "dn_short_output: no memory\n");
 			kfree_skb(skb);
 			return -ENOBUFS;
 		}
@@ -316,8 +312,6 @@ static int dn_phase3_output(struct neighbour *neigh, struct sk_buff *skb)
 	if (skb_headroom(skb) < headroom) {
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, headroom);
 		if (skb2 == NULL) {
-			if (net_ratelimit())
-				printk(KERN_CRIT "dn_phase3_output: no memory\n");
 			kfree_skb(skb);
 			return -ENOBUFS;
 		}
-- 
1.7.6.405.gc1be0
