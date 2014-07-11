From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] net: ipv6: Use BUG_ON
Date: Sat, 12 Jul 2014 01:55:38 +0530
Message-ID: <20140711202538.GA3766@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The semantic patch that makes the transformation is as follows:

// <smpl>
@@ expression e; @@
-if (e) BUG();
+BUG_ON(e);
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
To send to: "David S. Miller" <davem@davemloft.net>,Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,James Morris <jmorris@namei.org>,Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,Patrick McHardy <kaber@trash.net>,netdev@vger.kernel.org,linux-kernel@vger.kernel.org
 net/ipv6/raw.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index b2dc60b..dee80fb 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -588,8 +588,7 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 	}
 
 	offset += skb_transport_offset(skb);
-	if (skb_copy_bits(skb, offset, &csum, 2))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, offset, &csum, 2));
 
 	/* in case cksum was not initialized */
 	if (unlikely(csum))
@@ -601,8 +600,7 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 	if (csum == 0 && fl6->flowi6_proto == IPPROTO_UDP)
 		csum = CSUM_MANGLED_0;
 
-	if (skb_store_bits(skb, offset, &csum, 2))
-		BUG();
+	BUG_ON(skb_store_bits(skb, offset, &csum, 2));
 
 send:
 	err = ip6_push_pending_frames(sk);
-- 
1.9.1
