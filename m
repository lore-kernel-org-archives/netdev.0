From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 14/14] pktgen: increase version
Date: Thu, 27 Aug 2009 16:55:20 -0700
Message-ID: <20090827235706.220395356@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35397 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724AbZH0X7P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:15 -0400
Content-Disposition: inline; filename=pktgen-version.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase module version, and cleanup module info.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/net/core/pktgen.c	2009-08-27 16:30:05.614687981 -0700
+++ b/net/core/pktgen.c	2009-08-27 16:34:18.584537961 -0700
@@ -169,9 +169,7 @@
 #include <asm/dma.h>
 #include <asm/div64.h>		/* do_div */
 
-#define VERSION \
-	"pktgen v2.70: Packet Generator for packet performance testing.\n"
-
+#define VERSION 	"2.72"
 #define IP_NAME_SZ 32
 #define MAX_MPLS_LABELS 16 /* This is the max label stack depth */
 #define MPLS_STACK_BOTTOM htonl(0x00000100)
@@ -422,7 +420,8 @@ static inline int ktime_lt(const ktime_t
 	return cmp1.tv64 < cmp2.tv64;
 }
 
-static const char version[] __initconst = VERSION;
+static const char version[] =
+	"pktgen " VERSION ": Packet Generator for packet performance testing.\n";
 
 static int pktgen_remove_device(struct pktgen_thread *t, struct pktgen_dev *i);
 static int pktgen_add_device(struct pktgen_thread *t, const char *ifname);
@@ -459,7 +458,7 @@ static struct notifier_block pktgen_noti
 
 static int pgctrl_show(struct seq_file *seq, void *v)
 {
-	seq_puts(seq, VERSION);
+	seq_puts(seq, version);
 	return 0;
 }
 
@@ -3852,10 +3851,15 @@ static void __exit pg_cleanup(void)
 module_init(pg_init);
 module_exit(pg_cleanup);
 
-MODULE_AUTHOR("Robert Olsson <robert.olsson@its.uu.se");
+MODULE_AUTHOR("Robert Olsson <robert.olsson@its.uu.se>");
 MODULE_DESCRIPTION("Packet Generator tool");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(VERSION);
 module_param(pg_count_d, int, 0);
+MODULE_PARM_DESC(pg_count_d, "Default number of packets to inject");
 module_param(pg_delay_d, int, 0);
+MODULE_PARM_DESC(pg_delay_d, "Default delay between packets (nanoseconds)");
 module_param(pg_clone_skb_d, int, 0);
+MODULE_PARM_DESC(pg_clone_skb_d, "Default number of copies of the same packet");
 module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Enable debugging of pktgen module");

-- 

