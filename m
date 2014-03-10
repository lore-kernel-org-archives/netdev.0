From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 4/5] skbuff: skb_segment: s/fskb/list_skb/
Date: Mon, 10 Mar 2014 19:27:59 +0200
Message-ID: <1394468807-25980-5-git-send-email-mst@redhat.com>
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
	=?us-ascii?Q?=3D=3Fus-ascii=3FB=3FPT9VVEYtOD9xP1BldGVyPTIwUGFuPTI4PUU2?=
	 =?us-ascii?Q?PUJEPTk4PUU1PThEPUFC=3F=3D_=3D=3Fus-ascii=3FB=3FPUU1PUI5PUIz?=
	 =?us-ascii?Q?PTI5Pz0=3D=3F=3D?= <panweiping3@gmail.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394468807-25980-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fskb is unrelated to frag: it's coming from
frag_list. Rename it list_skb to avoid confusion.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/skbuff.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index af386e1..64ee4e6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2853,7 +2853,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 {
 	struct sk_buff *segs = NULL;
 	struct sk_buff *tail = NULL;
-	struct sk_buff *fskb = skb_shinfo(head_skb)->frag_list;
+	struct sk_buff *list_skb = skb_shinfo(head_skb)->frag_list;
 	skb_frag_t *frag = skb_shinfo(head_skb)->frags;
 	unsigned int mss = skb_shinfo(head_skb)->gso_size;
 	unsigned int doffset = head_skb->data - skb_mac_header(head_skb);
@@ -2894,14 +2894,14 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 		if (hsize > len || !sg)
 			hsize = len;
 
-		if (!hsize && i >= nfrags && skb_headlen(fskb) &&
-		    (skb_headlen(fskb) == len || sg)) {
-			BUG_ON(skb_headlen(fskb) > len);
+		if (!hsize && i >= nfrags && skb_headlen(list_skb) &&
+		    (skb_headlen(list_skb) == len || sg)) {
+			BUG_ON(skb_headlen(list_skb) > len);
 
 			i = 0;
-			nfrags = skb_shinfo(fskb)->nr_frags;
-			frag = skb_shinfo(fskb)->frags;
-			pos += skb_headlen(fskb);
+			nfrags = skb_shinfo(list_skb)->nr_frags;
+			frag = skb_shinfo(list_skb)->frags;
+			pos += skb_headlen(list_skb);
 
 			while (pos < offset + len) {
 				BUG_ON(i >= nfrags);
@@ -2915,8 +2915,8 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 				frag++;
 			}
 
-			nskb = skb_clone(fskb, GFP_ATOMIC);
-			fskb = fskb->next;
+			nskb = skb_clone(list_skb, GFP_ATOMIC);
+			list_skb = list_skb->next;
 
 			if (unlikely(!nskb))
 				goto err;
@@ -2983,15 +2983,15 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 
 		while (pos < offset + len) {
 			if (i >= nfrags) {
-				BUG_ON(skb_headlen(fskb));
+				BUG_ON(skb_headlen(list_skb));
 
 				i = 0;
-				nfrags = skb_shinfo(fskb)->nr_frags;
-				frag = skb_shinfo(fskb)->frags;
+				nfrags = skb_shinfo(list_skb)->nr_frags;
+				frag = skb_shinfo(list_skb)->frags;
 
 				BUG_ON(!nfrags);
 
-				fskb = fskb->next;
+				list_skb = list_skb->next;
 			}
 
 			if (unlikely(skb_shinfo(nskb)->nr_frags >=
-- 
MST
