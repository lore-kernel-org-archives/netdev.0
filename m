From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] IrDA prototype fixes
Date: Sat, 3 Sep 2005 03:47:31 +0200
Message-ID: <20050903014731.GH3657@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161085AbVICBrm@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Every file should #include the header files containing the prototypes of
it's global functions.

In this case this showed that the prototype of irlan_print_filter() was 
wrong which is also corrected in this patch.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/irda/irlan_filter.h |    2 +-
 net/irda/irlan/irlan_filter.c   |    1 +
 net/irda/qos.c                  |    1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

--- linux-2.6.13-mm1-full/net/irda/qos.c.old	2005-09-03 02:23:07.000000000 +0200
+++ linux-2.6.13-mm1-full/net/irda/qos.c	2005-09-03 02:23:31.000000000 +0200
@@ -37,6 +37,7 @@
 #include <net/irda/parameters.h>
 #include <net/irda/qos.h>
 #include <net/irda/irlap.h>
+#include <net/irda/irlap_frame.h>
 
 /*
  * Maximum values of the baud rate we negociate with the other end.
--- linux-2.6.13-mm1-full/include/net/irda/irlan_filter.h.old	2005-09-03 02:43:20.000000000 +0200
+++ linux-2.6.13-mm1-full/include/net/irda/irlan_filter.h	2005-09-03 02:43:29.000000000 +0200
@@ -28,6 +28,6 @@
 void irlan_check_command_param(struct irlan_cb *self, char *param, 
 			       char *value);
 void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb);
-int irlan_print_filter(struct seq_file *seq, int filter_type);
+void irlan_print_filter(struct seq_file *seq, int filter_type);
 
 #endif /* IRLAN_FILTER_H */
--- linux-2.6.13-mm1-full/net/irda/irlan/irlan_filter.c.old	2005-09-03 02:25:06.000000000 +0200
+++ linux-2.6.13-mm1-full/net/irda/irlan/irlan_filter.c	2005-09-03 02:25:24.000000000 +0200
@@ -27,6 +27,7 @@
 #include <linux/seq_file.h>
 
 #include <net/irda/irlan_common.h>
+#include <net/irda/irlan_filter.h>
 
 /*
  * Function irlan_filter_request (self, skb)
