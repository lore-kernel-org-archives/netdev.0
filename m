From: kaber@trash.net
Subject: [PATCH 04/79] netfilter: ct_extend: fix the wrong alloc_size
Date: Wed, 19 Jan 2011 20:14:04 +0100
Message-ID: <1295464519-21763-5-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51970 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511Ab1ASTPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:24 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

In function update_alloc_size(), sizeof(struct nf_ct_ext) is added twice
wrongly.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_extend.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

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
-- 
1.7.2.3

