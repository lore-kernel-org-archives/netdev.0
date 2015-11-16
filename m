From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 2/3] libceph: use list_next_entry instead of list_entry_next
Date: Mon, 16 Nov 2015 21:46:32 +0800
Message-ID: <b6930bdf479389886e7b999d207419836893af78.1447681244.git.geliangtang@163.com>
References: <6a47dadb3a625d7f5b20b4e98bb8af4d30db66a3.1447681244.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>,
	Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6a47dadb3a625d7f5b20b4e98bb8af4d30db66a3.1447681244.git.geliangtang@163.com>
In-Reply-To: <6a47dadb3a625d7f5b20b4e98bb8af4d30db66a3.1447681244.git.geliangtang@163.com>
References: <6a47dadb3a625d7f5b20b4e98bb8af4d30db66a3.1447681244.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

list_next_entry has been defined in list.h, so I replace list_entry_next
with it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/ceph/messenger.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 9981039..b1d1489 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -23,9 +23,6 @@
 #include <linux/ceph/pagelist.h>
 #include <linux/export.h>
 
-#define list_entry_next(pos, member)					\
-	list_entry(pos->member.next, typeof(*pos), member)
-
 /*
  * Ceph uses the messenger to exchange ceph_msg messages with other
  * hosts in the system.  The messenger provides ordered and reliable
@@ -1042,7 +1039,7 @@ static bool ceph_msg_data_pagelist_advance(struct ceph_msg_data_cursor *cursor,
 	/* Move on to the next page */
 
 	BUG_ON(list_is_last(&cursor->page->lru, &pagelist->head));
-	cursor->page = list_entry_next(cursor->page, lru);
+	cursor->page = list_next_entry(cursor->page, lru);
 	cursor->last_piece = cursor->resid <= PAGE_SIZE;
 
 	return true;
@@ -1166,7 +1163,7 @@ static bool ceph_msg_data_advance(struct ceph_msg_data_cursor *cursor,
 	if (!cursor->resid && cursor->total_resid) {
 		WARN_ON(!cursor->last_piece);
 		BUG_ON(list_is_last(&cursor->data->links, cursor->data_head));
-		cursor->data = list_entry_next(cursor->data, links);
+		cursor->data = list_next_entry(cursor->data, links);
 		__ceph_msg_data_cursor_init(cursor);
 		new_piece = true;
 	}
-- 
2.5.0
