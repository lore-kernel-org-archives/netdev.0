From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Make LLC2 compile with PROC_FS=n
Date: Mon, 20 Oct 2003 10:16:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020101607.76e02647.shemminger@osdl.org>
References: <Pine.GSO.4.58.0310171452540.13905@blinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, rddunlap@osdl.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Noah J. Misch" <noah@caltech.edu>
In-Reply-To: <Pine.GSO.4.58.0310171452540.13905@blinky>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Why make up a whole separate llc_proc.h file for two prototypes? 
Put them on the end of llc.h

diff -Nru a/include/net/llc.h b/include/net/llc.h
--- a/include/net/llc.h	Mon Oct 20 10:14:56 2003
+++ b/include/net/llc.h	Mon Oct 20 10:14:56 2003
@@ -88,4 +88,12 @@
 
 extern int llc_station_init(void);
 extern void llc_station_exit(void);
+
+#ifdef CONFIG_PROC_FS
+extern int llc_proc_init(void);
+extern void llc_proc_exit(void);
+#else
+#define llc_proc_init()	(0)
+#define llc_proc_exit()	do { } while(0)
+#endif /* CONFIG_PROC_FS */
 #endif /* LLC_H */
diff -Nru a/include/net/llc_proc.h b/include/net/llc_proc.h
--- a/include/net/llc_proc.h	Mon Oct 20 10:14:56 2003
+++ /dev/null	Wed Dec 31 16:00:00 1969
@@ -1,18 +0,0 @@
-#ifndef LLC_PROC_H
-#define LLC_PROC_H
-/*
- * Copyright (c) 1997 by Procom Technology, Inc.
- * 		 2002 by Arnaldo Carvalho de Melo <acme@conectiva.com.br>
- *
- * This program can be redistributed or modified under the terms of the
- * GNU General Public License as published by the Free Software Foundation.
- * This program is distributed without any warranty or implied warranty
- * of merchantability or fitness for a particular purpose.
- *
- * See the GNU General Public License for more details.
- */
-
-extern int llc_proc_init(void);
-extern void llc_proc_exit(void);
-
-#endif /* LLC_PROC_H */
diff -Nru a/net/llc/af_llc.c b/net/llc/af_llc.c
--- a/net/llc/af_llc.c	Mon Oct 20 10:14:56 2003
+++ b/net/llc/af_llc.c	Mon Oct 20 10:14:56 2003
@@ -30,7 +30,6 @@
 #include <net/llc_sap.h>
 #include <net/llc_pdu.h>
 #include <net/llc_conn.h>
-#include <net/llc_proc.h>
 
 /* remember: uninitialized global data is zeroed because its in .bss */
 static u16 llc_ui_sap_last_autoport = LLC_SAP_DYN_START;
diff -Nru a/net/llc/llc_proc.c b/net/llc/llc_proc.c
--- a/net/llc/llc_proc.c	Mon Oct 20 10:14:56 2003
+++ b/net/llc/llc_proc.c	Mon Oct 20 10:14:56 2003
@@ -14,7 +14,6 @@
 
 #include <linux/config.h>
 #include <linux/init.h>
-#ifdef CONFIG_PROC_FS
 #include <linux/kernel.h>
 #include <linux/proc_fs.h>
 #include <linux/errno.h>
@@ -273,13 +272,3 @@
 	remove_proc_entry("core", llc_proc_dir);
 	remove_proc_entry("llc", proc_net);
 }
-#else /* CONFIG_PROC_FS */
-int __init llc_proc_init(void)
-{
-	return 0;
-}
-
-void llc_proc_exit(void)
-{
-}
-#endif /* CONFIG_PROC_FS */
