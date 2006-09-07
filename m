From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/2][ATM]: proper prototypes in net/atm/mpc.h (and reduce ifdef clutter)
Date: Thu, 07 Sep 2006 17:59:37 -0400
Message-ID: <200609072159.k87LxbAH022184@relax.cmf.nrl.navy.mil>
Cc: davem@davemloft.net, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:60131 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1751903AbWIGWHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 18:07:25 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: proper prototypes in net/atm/mpc.h (and reduce ifdef clutter)

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 0d60b74cf4354672e4586ca2bedde6695db43165
tree 6d87bc63ee248fee449133cb62614f963fc97f54
parent 0293994f3f7a3a4bc4db6e286473e9b422b8f582
author chas williams <chas@relax.cmf.nrl.navy.mil> Thu, 07 Sep 2006 15:56:26 -0400
committer chas williams <chas@relax.cmf.nrl.navy.mil> Thu, 07 Sep 2006 15:56:26 -0400

 net/atm/mpc.c |   11 -----------
 net/atm/mpc.h |    8 ++++++++
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 0070466..b87c2a8 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -98,11 +98,6 @@ static struct notifier_block mpoa_notifi
 	0
 };
 
-#ifdef CONFIG_PROC_FS
-extern int mpc_proc_init(void);
-extern void mpc_proc_clean(void);
-#endif
-
 struct mpoa_client *mpcs = NULL; /* FIXME */
 static struct atm_mpoa_qos *qos_head = NULL;
 static DEFINE_TIMER(mpc_timer, NULL, 0, 0);
@@ -1439,12 +1434,8 @@ static __init int atm_mpoa_init(void)
 {
 	register_atm_ioctl(&atm_ioctl_ops);
 
-#ifdef CONFIG_PROC_FS
 	if (mpc_proc_init() != 0)
 		printk(KERN_INFO "mpoa: failed to initialize /proc/mpoa\n");
-	else
-		printk(KERN_INFO "mpoa: /proc/mpoa initialized\n");
-#endif
 
 	printk("mpc.c: " __DATE__ " " __TIME__ " initialized\n");
 
@@ -1457,9 +1448,7 @@ static void __exit atm_mpoa_cleanup(void
 	struct atm_mpoa_qos *qos, *nextqos;
 	struct lec_priv *priv;
 
-#ifdef CONFIG_PROC_FS
 	mpc_proc_clean();
-#endif
 
 	del_timer(&mpc_timer);
 	unregister_netdevice_notifier(&mpoa_notifier);
diff --git a/net/atm/mpc.h b/net/atm/mpc.h
index 863ddf6..3c7981a 100644
--- a/net/atm/mpc.h
+++ b/net/atm/mpc.h
@@ -50,4 +50,12 @@ int atm_mpoa_delete_qos(struct atm_mpoa_
 struct seq_file;
 void atm_mpoa_disp_qos(struct seq_file *m);
 
+#ifdef CONFIG_PROC_FS
+int mpc_proc_init(void);
+void mpc_proc_clean(void);
+#else
+#define mpc_proc_init() (0)
+#define mpc_proc_clean() do { } while(0)
+#endif
+
 #endif /* _MPC_H_ */
