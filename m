From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 1/4]: Add rb_last()
Date: Sat, 14 Aug 2004 22:00:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411E6F4E.6010705@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000107040408030403080905"
Cc: netdev@oss.sgi.com, devik <devik@cdi.cz>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000107040408030403080905
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds rb_last which returns the last element in sort-order
from a rbtree.


--------------000107040408030403080905
Content-Type: text/x-patch;
 name="01-hfsc-2.6.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01-hfsc-2.6.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/11 23:09:51+02:00 kaber@coreworks.de 
#   [RBTREE]: Add rb_last()
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# lib/rbtree.c
#   2004/08/11 23:09:34+02:00 kaber@coreworks.de +13 -0
#   [RBTREE]: Add rb_last()
# 
# include/linux/rbtree.h
#   2004/08/11 23:09:34+02:00 kaber@coreworks.de +1 -0
#   [RBTREE]: Add rb_last()
# 
diff -Nru a/include/linux/rbtree.h b/include/linux/rbtree.h
--- a/include/linux/rbtree.h	2004-08-12 23:25:04 +02:00
+++ b/include/linux/rbtree.h	2004-08-12 23:25:04 +02:00
@@ -123,6 +123,7 @@
 extern struct rb_node *rb_next(struct rb_node *);
 extern struct rb_node *rb_prev(struct rb_node *);
 extern struct rb_node *rb_first(struct rb_root *);
+extern struct rb_node *rb_last(struct rb_root *);
 
 /* Fast replacement of a single node without remove/rebalance/add/rebalance */
 extern void rb_replace_node(struct rb_node *victim, struct rb_node *new, 
diff -Nru a/lib/rbtree.c b/lib/rbtree.c
--- a/lib/rbtree.c	2004-08-12 23:25:04 +02:00
+++ b/lib/rbtree.c	2004-08-12 23:25:04 +02:00
@@ -312,6 +312,19 @@
 }
 EXPORT_SYMBOL(rb_first);
 
+struct rb_node *rb_last(struct rb_root *root)
+{
+	struct rb_node	*n;
+
+	n = root->rb_node;
+	if (!n)
+		return NULL;
+	while (n->rb_right)
+		n = n->rb_right;
+	return n;
+}
+EXPORT_SYMBOL(rb_last);
+
 struct rb_node *rb_next(struct rb_node *node)
 {
 	/* If we have a right-hand child, go down and then left as far

--------------000107040408030403080905--
