From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 15/19] list: introduce list_for_each_entry_from_reverse helper
Date: Fri,  3 Feb 2017 10:29:05 +0100
Message-ID: <1486114149-7941-16-git-send-email-jiri@resnulli.us>
References: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com, tom@herbertland.com,
        f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36518 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752672AbdBCJ3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:29:30 -0500
Received: by mail-wm0-f66.google.com with SMTP id r18so3091112wmd.3
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 01:29:29 -0800 (PST)
In-Reply-To: <1486114149-7941-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Similar to list_for_each_entry_continue and its reverse variant
list_for_each_entry_continue_reverse, introduce reverse helper for
list_for_each_entry_from.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
 include/linux/list.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/list.h b/include/linux/list.h
index d1039ec..ae537fa 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -527,6 +527,19 @@ static inline void list_splice_tail_init(struct list_head *list,
 	     pos = list_next_entry(pos, member))
 
 /**
+ * list_for_each_entry_from_reverse - iterate backwards over list of given type
+ *                                    from the current point
+ * @pos:	the type * to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the list_head within the struct.
+ *
+ * Iterate backwards over list of given type, continuing from current position.
+ */
+#define list_for_each_entry_from_reverse(pos, head, member)		\
+	for (; &pos->member != (head);					\
+	     pos = list_prev_entry(pos, member))
+
+/**
  * list_for_each_entry_safe - iterate over list of given type safe against removal of list entry
  * @pos:	the type * to use as a loop cursor.
  * @n:		another type * to use as temporary storage
-- 
2.7.4
