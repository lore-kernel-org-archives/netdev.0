From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ceph: [PATCH] ceph: use list_move_tail instead of list_del/list_add_tail
Date: Wed, 5 Sep 2012 14:34:32 +0800
Message-ID: <CAPgLHd-+oONn90yq4yy6-NKDcSwTduqu44ZUFbSCDP8bci84qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: sage@inktank.com, davem@davemloft.net
Return-path: <ceph-devel-owner@vger.kernel.org>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_move_tail() instead of list_del() + list_add_tail().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/ceph/pagelist.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index 665cd23..92866be 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -1,4 +1,3 @@
-
 #include <linux/module.h>
 #include <linux/gfp.h>
 #include <linux/pagemap.h>
@@ -134,8 +133,8 @@ int ceph_pagelist_truncate(struct ceph_pagelist *pl,
 	ceph_pagelist_unmap_tail(pl);
 	while (pl->head.prev != c->page_lru) {
 		page = list_entry(pl->head.prev, struct page, lru);
-		list_del(&page->lru);                /* remove from pagelist */
-		list_add_tail(&page->lru, &pl->free_list); /* add to reserve */
+		/* move from pagelist to reserve */
+		list_move_tail(&page->lru, &pl->free_list);
 		++pl->num_pages_free;
 	}
 	pl->room = c->room;

