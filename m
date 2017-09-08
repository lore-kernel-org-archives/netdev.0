From: zhizhou.tian@gmail.com
Subject: [PATCH] net:netfilter alloc xt_byteslimit_htable with wrong size
Date: Fri,  8 Sep 2017 11:00:16 +0800
Message-ID: <1504839616-14519-1-git-send-email-zhizhou.tian@gmail.com>
Cc: Zhizhou Tian <zhizhou.tian@gmail.com>
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de,
        davem@davemloft.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhizhou Tian <zhizhou.tian@gmail.com>

struct xt_byteslimit_htable used hlist_head,
but alloc memory with sizeof(struct list_head)

Change-Id: I75bc60e47e0823700d4303c9d763b7995e3b7bb3
Signed-off-by: Zhizhou Tian <zhizhou.tian@gmail.com>
---
 net/netfilter/xt_hashlimit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 10d4823..962ea4a 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -279,7 +279,7 @@ static int htable_create(struct net *net, struct hashlimit_cfg3 *cfg,
 		size = cfg->size;
 	} else {
 		size = (totalram_pages << PAGE_SHIFT) / 16384 /
-		       sizeof(struct list_head);
+		       sizeof(struct hlist_head);
 		if (totalram_pages > 1024 * 1024 * 1024 / PAGE_SIZE)
 			size = 8192;
 		if (size < 16)
@@ -287,7 +287,7 @@ static int htable_create(struct net *net, struct hashlimit_cfg3 *cfg,
 	}
 	/* FIXME: don't use vmalloc() here or anywhere else -HW */
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
-	                sizeof(struct list_head) * size);
+	                sizeof(struct hlist_head) * size);
 	if (hinfo == NULL)
 		return -ENOMEM;
 	*out_hinfo = hinfo;
-- 
2.7.4

