From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: fix the wrong alloc_size
Date: Sun, 14 Nov 2010 14:35:48 +0800
Message-ID: <1289716548-30767-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function update_alloc_size(), sizeof(struct nf_ct_ext) is added twice
wrongly.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/nf_conntrack_extend.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index bd82450..920f924 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -144,9 +144,8 @@ static void update_alloc_size(struct nf_ct_ext_type *type)
 		if (!t1)
 			continue;
 
-		t1->alloc_size = sizeof(struct nf_ct_ext)
-				 + ALIGN(sizeof(struct nf_ct_ext), t1->align)
-				 + t1->len;
+		t1->alloc_size = ALIGN(sizeof(struct nf_ct_ext), t1->align) +
+				 t1->len;
 		for (j = 0; j < NF_CT_EXT_NUM; j++) {
 			t2 = nf_ct_ext_types[j];
 			if (t2 == NULL || t2 == t1 ||
