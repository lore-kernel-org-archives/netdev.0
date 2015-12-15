From: William Hua <william.hua@canonical.com>
Subject: [PATCH] rhashtable: Always allocate at least one bucket lock
Date: Tue, 15 Dec 2015 17:45:59 -0500
Message-ID: <56709827.1010407@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: William Hua <william.hua@canonical.com>
To: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35697 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965549AbbLOWqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 17:46:01 -0500
Received: by mail-io0-f182.google.com with SMTP id q126so36248692iof.2
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 14:46:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No bucket locks are allocated when an rhashtable is initialized with
fewer than two elements. In this special case, we should allocate at
least one to prevent a segfault.

Signed-off-by: William Hua <william.hua@canonical.com>
---
 lib/rhashtable.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index a54ff89..1b1b5b2 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -76,6 +76,9 @@ static int alloc_bucket_locks(struct rhashtable *ht, struct bucket_table *tbl,
 	/* Never allocate more than 0.5 locks per bucket */
 	size = min_t(unsigned int, size, tbl->size >> 1);
 
+	/* Always allocate at least one lock */
+	size = max_t(unsigned int, size, 1);
+
 	if (sizeof(spinlock_t) != 0) {
 #ifdef CONFIG_NUMA
 		if (size * sizeof(spinlock_t) > PAGE_SIZE &&
-- 
2.6.4
