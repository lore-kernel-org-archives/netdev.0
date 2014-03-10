From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/5] skbuff: skb_segment: s/skb_frag/frag/
Date: Mon, 10 Mar 2014 18:29:14 +0200
Message-ID: <1394468807-25980-3-git-send-email-mst@redhat.com>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbenc@redhat.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Simon Horman <horms@verge.net.au>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miklos Szeredi <mszeredi@suse.cz>,
	=?us-ascii?B?PT9VVEYtOD9xP1BldGVyPTIwUGFuPTI4PUU2PUJEPTk4PUU1PThEPUFC?=
	 =?us-ascii?B?PUU1PUI5PUIzPTI5Pz0=?= <panweiping3@gmail.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394468807-25980-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb_frag can in fact point at either skb
or fskb so rename it generally "frag".

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/skbuff.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3bc6d75..917cb60 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2853,7 +2853,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	struct sk_buff *segs = NULL;
 	struct sk_buff *tail = NULL;
 	struct sk_buff *fskb = skb_shinfo(skb)->frag_list;
-	skb_frag_t *skb_frag = skb_shinfo(skb)->frags;
+	skb_frag_t *frag = skb_shinfo(skb)->frags;
 	unsigned int mss = skb_shinfo(skb)->gso_size;
 	unsigned int doffset = skb->data - skb_mac_header(skb);
 	unsigned int offset = doffset;
@@ -2899,19 +2899,19 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 			i = 0;
 			nfrags = skb_shinfo(fskb)->nr_frags;
-			skb_frag = skb_shinfo(fskb)->frags;
+			frag = skb_shinfo(fskb)->frags;
 			pos += skb_headlen(fskb);
 
 			while (pos < offset + len) {
 				BUG_ON(i >= nfrags);
 
-				size = skb_frag_size(skb_frag);
+				size = skb_frag_size(frag);
 				if (pos + size > offset + len)
 					break;
 
 				i++;
 				pos += size;
-				skb_frag++;
+				frag++;
 			}
 
 			nskb = skb_clone(fskb, GFP_ATOMIC);
@@ -2985,7 +2985,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 				i = 0;
 				nfrags = skb_shinfo(fskb)->nr_frags;
-				skb_frag = skb_shinfo(fskb)->frags;
+				frag = skb_shinfo(fskb)->frags;
 
 				BUG_ON(!nfrags);
 
@@ -3000,7 +3000,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 				goto err;
 			}
 
-			*nskb_frag = *skb_frag;
+			*nskb_frag = *frag;
 			__skb_frag_ref(nskb_frag);
 			size = skb_frag_size(nskb_frag);
 
@@ -3013,7 +3013,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 			if (pos + size <= offset + len) {
 				i++;
-				skb_frag++;
+				frag++;
 				pos += size;
 			} else {
 				skb_frag_size_sub(nskb_frag, pos + size - (offset + len));
-- 
MST
