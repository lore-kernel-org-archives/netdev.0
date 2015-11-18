From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 2/3] net/ceph: do not define list_entry_next
Date: Wed, 18 Nov 2015 21:13:00 +0900
Message-ID: <1447848780-7672-1-git-send-email-sergey.senozhatsky@gmail.com>
Cc: Ilya Dryomov <idryomov@gmail.com>, Yan Zheng <zyan@redhat.com>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34398 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbbKRMOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 07:14:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cosmetic.

Do not define list_entry_next() and use list_next_entry()
from list.h.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 net/ceph/messenger.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 9981039..77ccca9 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -10,6 +10,7 @@
 #include <linux/slab.h>
 #include <linux/socket.h>
 #include <linux/string.h>
+#include <linux/list.h>
 #ifdef	CONFIG_BLOCK
 #include <linux/bio.h>
 #endif	/* CONFIG_BLOCK */
@@ -23,9 +24,6 @@
 #include <linux/ceph/pagelist.h>
 #include <linux/export.h>
 
-#define list_entry_next(pos, member)					\
-	list_entry(pos->member.next, typeof(*pos), member)
-
 /*
  * Ceph uses the messenger to exchange ceph_msg messages with other
  * hosts in the system.  The messenger provides ordered and reliable
@@ -1042,7 +1040,7 @@ static bool ceph_msg_data_pagelist_advance(struct ceph_msg_data_cursor *cursor,
 	/* Move on to the next page */
 
 	BUG_ON(list_is_last(&cursor->page->lru, &pagelist->head));
-	cursor->page = list_entry_next(cursor->page, lru);
+	cursor->page = list_next_entry(cursor->page, lru);
 	cursor->last_piece = cursor->resid <= PAGE_SIZE;
 
 	return true;
@@ -1166,7 +1164,7 @@ static bool ceph_msg_data_advance(struct ceph_msg_data_cursor *cursor,
 	if (!cursor->resid && cursor->total_resid) {
 		WARN_ON(!cursor->last_piece);
 		BUG_ON(list_is_last(&cursor->data->links, cursor->data_head));
-		cursor->data = list_entry_next(cursor->data, links);
+		cursor->data = list_next_entry(cursor->data, links);
 		__ceph_msg_data_cursor_init(cursor);
 		new_piece = true;
 	}
-- 
2.6.2.280.g74301d6
