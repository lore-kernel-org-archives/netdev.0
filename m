From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 1/5] [bonding] backport 2.6 changes to 2.4
Date: Wed, 30 Jul 2003 20:07:00 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307302007.00926.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add list_for_each_entry_safe()

Amir

diff -Nuarp linux-2.4.22-pre9/include/linux/list.h linux-2.4.22-pre9-devel/include/linux/list.h
--- linux-2.4.22-pre9/include/linux/list.h	Wed Jul 30 19:14:01 2003
+++ linux-2.4.22-pre9-devel/include/linux/list.h	Wed Jul 30 19:14:02 2003
@@ -227,6 +227,19 @@ static inline void list_splice_init(stru
 	     pos = list_entry(pos->member.next, typeof(*pos), member),	\
 		     prefetch(pos->member.next))
 
+/**
+ * list_for_each_entry_safe - iterate over list of given type safe against removal of list entry
+ * @pos:	the type * to use as a loop counter.
+ * @n:		another type * to use as temporary storage
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_safe(pos, n, head, member)			\
+	for (pos = list_entry((head)->next, typeof(*pos), member),	\
+		n = list_entry(pos->member.next, typeof(*pos), member);	\
+	     &pos->member != (head); 					\
+	     pos = n, n = list_entry(n->member.next, typeof(*n), member))
+
 #endif /* __KERNEL__ || _LVM_H_INCLUDE */
 
 #endif
