From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] set owner field on /proc/net/irda sub entries
Date: Mon, 18 Aug 2003 11:19:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818111942.6060b450.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, irda-users@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

common net/irda code in 2.6.0-test3 creates directory and sub entries,
but forgets to set owner field on sub entries.

diff -Nru a/net/irda/irproc.c b/net/irda/irproc.c
--- a/net/irda/irproc.c	Mon Aug 18 11:08:23 2003
+++ b/net/irda/irproc.c	Mon Aug 18 11:08:23 2003
@@ -62,14 +62,18 @@
 void __init irda_proc_register(void) 
 {
 	int i;
+	struct proc_dir_entry *d;
 
 	proc_irda = proc_mkdir("net/irda", NULL);
 	if (proc_irda == NULL)
 		return;
 	proc_irda->owner = THIS_MODULE;
 
-	for (i=0; i<ARRAY_SIZE(dir); i++)
-		create_proc_info_entry(dir[i].name,0,proc_irda,dir[i].fn);
+	for (i=0; i<ARRAY_SIZE(dir); i++) {
+		d = create_proc_info_entry(dir[i].name,0,proc_irda,dir[i].fn);
+		if (d)
+			d->owner = THIS_MODULE;
+	}
 }
 
 /*
