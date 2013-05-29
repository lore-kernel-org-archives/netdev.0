From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] list: introduce list_first_entry_or_null
Date: Wed, 29 May 2013 17:02:56 +0200
Message-ID: <1369839777-19158-2-git-send-email-jiri@resnulli.us>
References: <1369839777-19158-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, sasha.levin@oracle.com,
	akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:48779 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966447Ab3E2PDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 11:03:04 -0400
Received: by mail-wi0-f179.google.com with SMTP id hq7so3599252wib.6
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 08:03:03 -0700 (PDT)
In-Reply-To: <1369839777-19158-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

non-rcu variant of list_first_or_null_rcu

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/list.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/list.h b/include/linux/list.h
index 6a1f8df..b83e565 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -362,6 +362,17 @@ static inline void list_splice_tail_init(struct list_head *list,
 	list_entry((ptr)->next, type, member)
 
 /**
+ * list_first_entry_or_null - get the first element from a list
+ * @ptr:	the list head to take the element from.
+ * @type:	the type of the struct this is embedded in.
+ * @member:	the name of the list_struct within the struct.
+ *
+ * Note that if the list is empty, it returns NULL.
+ */
+#define list_first_entry_or_null(ptr, type, member) \
+	(!list_empty(ptr) ? list_first_entry(ptr, type, member) : NULL)
+
+/**
  * list_for_each	-	iterate over a list
  * @pos:	the &struct list_head to use as a loop cursor.
  * @head:	the head for your list.
-- 
1.7.11.7
