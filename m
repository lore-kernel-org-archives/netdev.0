From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: [PATCH 2/4] list.h: add list_cut_position()
Date: Mon, 4 Aug 2008 15:48:09 -0700
Message-ID: <1217890089-12100-1-git-send-email-lrodriguez@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	<linux-wireless@vger.kernel.org>, <ath9k-devel@lists.ath9k.org>
To: <linville@tuxdriver.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linville@tuxdriver.com>,
	<torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:45867 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755931AbYHDWsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 18:48:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds list_cut_position() which lets you cut a list into
two lists given a pivot in the list.

Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
---
 include/linux/list.h |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index 594f67c..2999b0f 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -214,6 +214,38 @@ static inline int list_is_singular(const struct list_head *head)
 	return !list_empty(head) && (head->next == head->prev);
 }
 
+static inline void __list_cut_position(struct list_head *list,
+		struct list_head *head, struct list_head *entry)
+{
+	struct list_head *new_first =
+		(entry->next != head) ? entry->next : head;
+	list->next = head->next;
+	list->next->prev = list;
+	list->prev = entry;
+	entry->next = list;
+	head->next = new_first;
+	new_first->prev = head;
+}
+
+/**
+ * list_cut_position - cut a list into two
+ * @list: a new list to add all removed entries
+ * @head: a list with entries
+ * @entry: an entry within head, could be the head itself
+ *	and if so we won't won't cut the list
+ */
+static inline void list_cut_position(struct list_head *list,
+		struct list_head *head, struct list_head *entry)
+{
+	BUG_ON(list_empty(head));
+	if (list_is_singular(head))
+		BUG_ON(head->next != entry && head != entry);
+	if (entry == head)
+		INIT_LIST_HEAD(list);
+	else
+		__list_cut_position(list, head, entry);
+}
+
 static inline void __list_splice(const struct list_head *list,
 				 struct list_head *head)
 {
-- 
1.5.6.rc2.15.g457bb.dirty

