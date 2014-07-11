From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] ipv6: Use BUG_ON
Date: Sat, 12 Jul 2014 01:57:17 +0530
Message-ID: <20140711202717.GA3848@himangi-Dell>
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

The semantic patch that makes this transformation is as follows:

// <smpl>
@@ expression e; @@
-if (e) BUG();
+BUG_ON(e);
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
To send to: "David S. Miller" <davem@davemloft.net>,Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,James Morris <jmorris@namei.org>,Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,Patrick McHardy <kaber@trash.net>,netdev@vger.kernel.org,linux-kernel@vger.kernel.org
 net/ipv6/ip6_output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index fa83bdd..9b395c6 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -801,8 +801,8 @@ slow_path:
 		/*
 		 *	Copy a block of the IP datagram.
 		 */
-		if (skb_copy_bits(skb, ptr, skb_transport_header(frag), len))
-			BUG();
+		BUG_ON(skb_copy_bits(skb, ptr, skb_transport_header(frag),
+				     len));
 		left -= len;
 
 		fh->frag_off = htons(offset);
-- 
1.9.1
