From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: use %pF for /proc/net/ptype
Date: Fri, 14 Nov 2008 14:10:04 +0300
Message-ID: <20081114111004.GA3321@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:16869 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbYKNLGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 06:06:37 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1608166ugf.37
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 03:06:35 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Technically, patch changes format for modules, but I think nobody cares.

	-86dd          :ipv6:ipv6_rcv+0x0
	+86dd          ipv6_rcv+0x0/0x400 [ipv6]

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/dev.c |   32 ++------------------------------
 1 file changed, 2 insertions(+), 30 deletions(-)

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -108,7 +108,6 @@
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <linux/module.h>
-#include <linux/kallsyms.h>
 #include <linux/netpoll.h>
 #include <linux/rcupdate.h>
 #include <linux/delay.h>
@@ -2797,31 +2796,6 @@ static void ptype_seq_stop(struct seq_file *seq, void *v)
 	rcu_read_unlock();
 }
 
-static void ptype_seq_decode(struct seq_file *seq, void *sym)
-{
-#ifdef CONFIG_KALLSYMS
-	unsigned long offset = 0, symsize;
-	const char *symname;
-	char *modname;
-	char namebuf[128];
-
-	symname = kallsyms_lookup((unsigned long)sym, &symsize, &offset,
-				  &modname, namebuf);
-
-	if (symname) {
-		char *delim = ":";
-
-		if (!modname)
-			modname = delim = "";
-		seq_printf(seq, "%s%s%s%s+0x%lx", delim, modname, delim,
-			   symname, offset);
-		return;
-	}
-#endif
-
-	seq_printf(seq, "[%p]", sym);
-}
-
 static int ptype_seq_show(struct seq_file *seq, void *v)
 {
 	struct packet_type *pt = v;
@@ -2834,10 +2808,8 @@ static int ptype_seq_show(struct seq_file *seq, void *v)
 		else
 			seq_printf(seq, "%04x", ntohs(pt->type));
 
-		seq_printf(seq, " %-8s ",
-			   pt->dev ? pt->dev->name : "");
-		ptype_seq_decode(seq,  pt->func);
-		seq_putc(seq, '\n');
+		seq_printf(seq, " %-8s %pF\n",
+			   pt->dev ? pt->dev->name : "", pt->func);
 	}
 
 	return 0;
