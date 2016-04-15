From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 02/11] list: add list_for_each_entry_reverse macro
Date: Fri, 15 Apr 2016 09:51:44 +0200
Message-ID: <1460706713-5942-3-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38900 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbcDOHv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:51:59 -0400
Received: by mail-wm0-f49.google.com with SMTP id u206so20026928wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:51:59 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/list.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/list.h b/include/list.h
index cdebe4d..b549c3e 100644
--- a/include/list.h
+++ b/include/list.h
@@ -50,9 +50,15 @@ static inline void list_del(struct list_head *entry)
 #define list_first_entry(ptr, type, member) \
 	list_entry((ptr)->next, type, member)
 
+#define list_last_entry(ptr, type, member) \
+	list_entry((ptr)->prev, type, member)
+
 #define list_next_entry(pos, member) \
 	list_entry((pos)->member.next, typeof(*(pos)), member)
 
+#define list_prev_entry(pos, member) \
+	list_entry((pos)->member.prev, typeof(*(pos)), member)
+
 #define list_for_each_entry(pos, head, member)				\
 	for (pos = list_first_entry(head, typeof(*pos), member);	\
 	     &pos->member != (head);					\
@@ -64,6 +70,11 @@ static inline void list_del(struct list_head *entry)
 	     &pos->member != (head);					\
 	     pos = n, n = list_next_entry(n, member))
 
+#define list_for_each_entry_reverse(pos, head, member)			\
+	for (pos = list_last_entry(head, typeof(*pos), member);		\
+	     &pos->member != (head);					\
+	     pos = list_prev_entry(pos, member))
+
 struct hlist_head {
 	struct hlist_node *first;
 };
-- 
2.5.5
