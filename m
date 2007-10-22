From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/3] Don't declare extern variables in net/core/sysctl_net_core.c
Date: Mon, 22 Oct 2007 19:22:43 +0400
Message-ID: <471CC043.5060301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58192 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbXJVPWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 11:22:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some are already declared in include/linux/netdevice.h, while
some others (xfrm ones) need to be declared.

The driver/net/rrunner.c just uses same extern as well, so 
cleanup it also.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 19152f5..b822859 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -79,12 +79,10 @@ static char version[] __devinitdata = "rrunner.c: v0.50 11/11/2002  Jes Sorensen
  */
 
 /*
- * These are checked at init time to see if they are at least 256KB
- * and increased to 256KB if they are not. This is done to avoid ending
- * up with socket buffers smaller than the MTU size,
+ * sysctl_[wr]mem_max are checked at init time to see if they are at
+ * least 256KB and increased to 256KB if they are not. This is done to
+ * avoid ending up with socket buffers smaller than the MTU size,
  */
-extern __u32 sysctl_wmem_max;
-extern __u32 sysctl_rmem_max;
 
 static int __devinit rr_init_one(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 688f6f5..58dfa82 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -37,6 +37,8 @@
 extern struct sock *xfrm_nl;
 extern u32 sysctl_xfrm_aevent_etime;
 extern u32 sysctl_xfrm_aevent_rseqth;
+extern int sysctl_xfrm_larval_drop;
+extern u32 sysctl_xfrm_acq_expires;
 
 extern struct mutex xfrm_cfg_mutex;
 
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 6d5ea97..113cc72 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -9,25 +9,12 @@
 #include <linux/sysctl.h>
 #include <linux/module.h>
 #include <linux/socket.h>
+#include <linux/netdevice.h>
 #include <net/sock.h>
+#include <net/xfrm.h>
 
 #ifdef CONFIG_SYSCTL
 
-extern int netdev_max_backlog;
-extern int weight_p;
-
-extern __u32 sysctl_wmem_max;
-extern __u32 sysctl_rmem_max;
-
-extern int sysctl_core_destroy_delay;
-
-#ifdef CONFIG_XFRM
-extern u32 sysctl_xfrm_aevent_etime;
-extern u32 sysctl_xfrm_aevent_rseqth;
-extern int sysctl_xfrm_larval_drop;
-extern u32 sysctl_xfrm_acq_expires;
-#endif
-
 ctl_table core_table[] = {
 #ifdef CONFIG_NET
 	{
-- 
1.5.3.4

