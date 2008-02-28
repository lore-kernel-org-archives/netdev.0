From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 06/15] [IRDA]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:56:39 +0800
Message-ID: <47C69367.6000609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52812 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754403AbYB1K7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 05:59:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/irda/ircomm/ircomm_core.c |    7 ++-----
 net/irda/irlan/irlan_common.c |    7 ++-----
 net/irda/irproc.c             |    8 +++-----
 3 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/net/irda/ircomm/ircomm_core.c b/net/irda/ircomm/ircomm_core.c
index b825399..aeaa30e 100644
--- a/net/irda/ircomm/ircomm_core.c
+++ b/net/irda/ircomm/ircomm_core.c
@@ -75,11 +75,8 @@ static int __init ircomm_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	{ struct proc_dir_entry *ent;
-	ent = create_proc_entry("ircomm", 0, proc_irda);
-	if (ent)
-		ent->proc_fops = &ircomm_proc_fops;
-	}
+	struct proc_dir_entry *ent;
+	ent = proc_create("ircomm", 0, proc_irda, &ircomm_proc_fops);
 #endif /* CONFIG_PROC_FS */
 
 	IRDA_MESSAGE("IrCOMM protocol (Dag Brattli)\n");
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index a4b56e2..2325f94 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -127,15 +127,12 @@ static int __init irlan_init(void)
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
 
 #ifdef CONFIG_PROC_FS
-	{ struct proc_dir_entry *proc;
-	proc = create_proc_entry("irlan", 0, proc_irda);
+	struct proc_dir_entry *proc;
+	proc = proc_create("irlan", 0, proc_irda, &irlan_fops);
 	if (!proc) {
 		printk(KERN_ERR "irlan_init: can't create /proc entry!\n");
 		return -ENODEV;
 	}
-
-	proc->proc_fops = &irlan_fops;
-	}
 #endif /* CONFIG_PROC_FS */
 
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
diff --git a/net/irda/irproc.c b/net/irda/irproc.c
index cae24fb..0ce80de 100644
--- a/net/irda/irproc.c
+++ b/net/irda/irproc.c
@@ -72,11 +72,9 @@ void __init irda_proc_register(void)
 		return;
 	proc_irda->owner = THIS_MODULE;
 
-	for (i=0; i<ARRAY_SIZE(irda_dirs); i++) {
-		d = create_proc_entry(irda_dirs[i].name, 0, proc_irda);
-		if (d)
-			d->proc_fops = irda_dirs[i].fops;
-	}
+	for (i=0; i<ARRAY_SIZE(irda_dirs); i++)
+		d = proc_create(irda_dirs[i].name, 0, proc_irda,
+				irda_dirs[i].fops);
 }
 
 /*
-- 
WCN


