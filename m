From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [SET 1][PATCH 1/6][bonding] backport 2.6 changes to 2.4
Date: Fri, 8 Aug 2003 17:44:16 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308081744.16738.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add list_for_each_entry_safe().

diff -Nuarp linux-2.4.22-rc1/include/linux/list.h linux-2.4.22-rc1-devel/include/linux/list.h
--- linux-2.4.22-rc1/include/linux/list.h	Fri Aug  8 14:02:24 2003
+++ linux-2.4.22-rc1-devel/include/linux/list.h	Fri Aug  8 14:02:25 2003
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

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
