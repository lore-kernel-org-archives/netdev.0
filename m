From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Limit SO_BSDCOMPAT warning
Date: Fri, 24 Oct 2003 22:57:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031024205707.GA1072@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Warning a few times for each process is enough.

-Andi

diff -u linux-2.6.0test7/net/core/sock.c-o linux-2.6.0test7mm1-averell/net/core/sock.c
--- linux-2.6.0test7mm1/net/core/sock.c-o	2003-10-16 05:19:13.000000000 +0200
+++ linux-2.6.0test7mm1/net/core/sock.c	2003-10-24 22:30:46.000000000 +0200
@@ -154,8 +154,14 @@
 
 static void sock_warn_obsolete_bsdism(const char *name)
 {
-	printk(KERN_WARNING "process `%s' is using obsolete "
-	       "%s SO_BSDCOMPAT\n", current->comm, name);
+	static int warned;
+	static char warncomm[16];
+	if (strcmp(warncomm, current->comm) && warned < 5) { 
+		strcpy(warncomm,  current->comm); 
+		printk(KERN_WARNING "process `%s' is using obsolete "
+		       "%s SO_BSDCOMPAT\n", warncomm, name);
+		warned++;
+	}
 }
 
 /*
