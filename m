From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] list.h: add list_for_each_struct_entry macro
Date: Mon, 18 Jan 2010 17:23:39 +0100
Message-ID: <20100118162338.GD4229@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754388Ab0ARQXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2010 11:23:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When preparing to upcoming migration of mc_list (list of multicast MACs)
to list_head, the need of traversing the list over one structure member
appeared. I thought I'll do it locally but I decided that an intruduction
the macro in list.h would be much clearer. Please kindly for a review.

Jirka

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/include/linux/list.h b/include/linux/list.h
index 969f6e9..8350a94 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -420,6 +420,22 @@ static inline void list_splice_tail_init(struct list_head *list,
 	     pos = list_entry(pos->member.prev, typeof(*pos), member))
 
 /**
+ * list_for_each_struct_entry  -       iterate over list of given type using
+ *                                     the struct member.
+ * @pos:       the type * to use as a loop cursor.
+ * @head:      the head for your list.
+ * @type:      the type of the struct.
+ * @posmember: the name ot the loop cursor within the struct.
+ * @member:    the name of the list_struct within the struct.
+ */
+#define list_for_each_struct_entry(pos, head, type, posmember, member)		\
+	for (pos = list_entry((head)->next, type, member)->posmember;		\
+	     prefetch(container_of(pos, type, posmember)->member.next),		\
+	     &container_of(pos, type, posmember)->member != (head);		\
+	     pos = list_entry(container_of(pos, type, posmember)->member.next,	\
+	     type, member)->posmember)
+
+/**
  * list_prepare_entry - prepare a pos entry for use in list_for_each_entry_continue()
  * @pos:	the type * to use as a start point
  * @head:	the head of the list
