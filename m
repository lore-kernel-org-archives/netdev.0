From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [clip] delay /proc/net/atm/arp creation
Date: Wed, 11 Feb 2004 09:32:29 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402111432.i1BEWRRr005897@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this patch delay's creation of /proc/net/atm/arp until
after the kmem_cache_create.  mea culpa in advance for
the shoddy #ifdef.

please apply to 2.6

thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1550  -> 1.1551 
#	      net/atm/clip.c	1.30    -> 1.31   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/10	chas@relax.cmf.nrl.navy.mil	1.1551
# [ATM]: [clip] delay /proc/net/atm/arp creation
# --------------------------------------------
#
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Tue Feb 10 17:05:22 2004
+++ b/net/atm/clip.c	Tue Feb 10 17:05:22 2004
@@ -1008,14 +1008,6 @@
 
 static int __init atm_clip_init(void)
 {
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *p;
-
-	p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
-	if (p)
-		p->proc_fops = &arp_seq_fops;
-#endif
-
 	/* we should use neigh_table_init() */
 	clip_tbl.lock = RW_LOCK_UNLOCKED;
 	clip_tbl.kmem_cachep = kmem_cache_create(clip_tbl.id,
@@ -1032,6 +1024,16 @@
 
 	clip_tbl_hook = &clip_tbl;
 	register_atm_ioctl(&clip_ioctl_ops);
+
+#ifdef CONFIG_PROC_FS
+{
+	struct proc_dir_entry *p;
+
+	p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
+	if (p)
+		p->proc_fops = &arp_seq_fops;
+}
+#endif
 
 	return 0;
 }
