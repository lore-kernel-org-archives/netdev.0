From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH net-next] skbuff: clear tx zero-copy flag
Date: Sat, 09 Jul 2011 00:12:46 -0700
Message-ID: <1310195566.25391.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

This patch clears tx zero-copy flag as needed.

Sign-off-by: Shirley Ma <xma@us.ibm.com>
---

 net/core/skbuff.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a9577a2..d220119 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -677,6 +677,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
 		if (skb_copy_ubufs(skb, gfp_mask))
 			return NULL;
+		skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 	}
 
 	n = skb + 1;
@@ -801,6 +802,7 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 				kfree(n);
 				goto out;
 			}
+			skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 		}
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
@@ -893,6 +895,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
 			if (skb_copy_ubufs(skb, gfp_mask))
 				goto nofrags;
+			skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 		}
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 			get_page(skb_shinfo(skb)->frags[i].page);
