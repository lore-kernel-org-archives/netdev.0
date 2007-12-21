From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 1/3] [XFRM]: Define packet dropping statistics.
Date: Fri, 21 Dec 2007 12:41:53 +0900
Message-ID: <11982085132010-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:58063 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754974AbXLUEJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:09:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This statistics is shown factor dropped by transformation
at /proc/net/xfrm_stat for developer.
It is a counter designed from current transformation source code
and defined as linux private MIB.

See Documentation/networking/xfrm_proc.txt for the detail.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 Documentation/networking/xfrm_proc.txt |   71 +++++++++++++++++++++++
 include/linux/snmp.h                   |   31 ++++++++++
 include/net/snmp.h                     |    5 ++
 include/net/xfrm.h                     |   18 ++++++
 net/xfrm/Makefile                      |    1 +
 net/xfrm/xfrm_policy.c                 |   24 ++++++++
 net/xfrm/xfrm_proc.c                   |   96 ++++++++++++++++++++++++++++++++
 7 files changed, 246 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/xfrm_proc.txt b/Documentation/networking/xfrm_proc.txt
new file mode 100644
index 0000000..ec9045b
--- /dev/null
+++ b/Documentation/networking/xfrm_proc.txt
@@ -0,0 +1,71 @@
+XFRM proc - /proc/net/xfrm_* files
+==================================
+Masahide NAKAMURA <nakam@linux-ipv6.org>
+
+
+Transformation Statistics
+-------------------------
+xfrm_proc is a statistics shown factor dropped by transformation
+for developer.
+It is a counter designed from current transformation source code
+and defined like linux private MIB.
+
+Inbound statistics
+~~~~~~~~~~~~~~~~~~
+XfrmInError:
+	All errors which is not matched others
+XfrmInBufferError:
+	No buffer is left
+XfrmInHdrError:
+	Header error
+XfrmInNoStates:
+	No state is found
+	i.e. Either inbound SPI, address, or IPsec protocol at SA is wrong
+XfrmInStateProtoError:
+	Transformation protocol specific error
+	e.g. SA key is wrong
+XfrmInStateModeError:
+	Transformation mode specific error
+XfrmInSeqOutOfWindow:
+	Sequence out of window
+XfrmInStateExpired:
+	State is expired
+XfrmInStateMismatch:
+	State has mismatch option
+	e.g. UDP encapsulation type is mismatch
+XfrmInStateInvalid:
+	State is invalid
+XfrmInTmplMismatch:
+	No matching template for states
+	e.g. Inbound SAs are correct but SP rule is wrong
+XfrmInNoPols:
+	No policy is found for states
+	e.g. Inbound SAs are correct but no SP is found
+XfrmInPolBlock:
+	Policy discards
+XfrmInPolError:
+	Policy error
+
+Outbound errors
+~~~~~~~~~~~~~~~
+XfrmOutError:
+	All errors which is not matched others
+XfrmOutBundleGenError:
+	Bundle generation error
+XfrmOutBundleCheckError:
+	Bundle check error
+XfrmOutNoStates:
+	No state is found
+XfrmOutStateProtoError:
+	Transformation protocol specific error
+XfrmOutStateModeError:
+	Transformation mode specific error
+	e.g. Outer header space is not enough
+XfrmOutStateExpired:
+	State is expired
+XfrmOutPolBlock:
+	Policy discards
+XfrmOutPolDead:
+	Policy is dead
+XfrmOutPolError:
+	Policy error
diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 89f0c2b..86d3eff 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -217,4 +217,35 @@ enum
 	__LINUX_MIB_MAX
 };
 
+/* linux Xfrm mib definitions */
+enum
+{
+	LINUX_MIB_XFRMNUM = 0,
+	LINUX_MIB_XFRMINERROR,			/* XfrmInError */
+	LINUX_MIB_XFRMINBUFFERERROR,		/* XfrmInBufferError */
+	LINUX_MIB_XFRMINHDRERROR,		/* XfrmInHdrError */
+	LINUX_MIB_XFRMINNOSTATES,		/* XfrmInNoStates */
+	LINUX_MIB_XFRMINSTATEPROTOERROR,	/* XfrmInStateProtoError */
+	LINUX_MIB_XFRMINSTATEMODEERROR,		/* XfrmInStateModeError */
+	LINUX_MIB_XFRMINSEQOUTOFWINDOW,		/* XfrmInSeqOutOfWindow */
+	LINUX_MIB_XFRMINSTATEEXPIRED,		/* XfrmInStateExpired */
+	LINUX_MIB_XFRMINSTATEMISMATCH,		/* XfrmInStateMismatch */
+	LINUX_MIB_XFRMINSTATEINVALID,		/* XfrmInStateInvalid */
+	LINUX_MIB_XFRMINTMPLMISMATCH,		/* XfrmInTmplMismatch */
+	LINUX_MIB_XFRMINNOPOLS,			/* XfrmInNoPols */
+	LINUX_MIB_XFRMINPOLBLOCK,		/* XfrmInPolBlock */
+	LINUX_MIB_XFRMINPOLERROR,		/* XfrmInPolError */
+	LINUX_MIB_XFRMOUTERROR,			/* XfrmOutError */
+	LINUX_MIB_XFRMOUTBUNDLEGENERROR,	/* XfrmOutBundleGenError */
+	LINUX_MIB_XFRMOUTBUNDLECHECKERROR,	/* XfrmOutBundleCheckError */
+	LINUX_MIB_XFRMOUTNOSTATES,		/* XfrmOutNoStates */
+	LINUX_MIB_XFRMOUTSTATEPROTOERROR,	/* XfrmOutStateProtoError */
+	LINUX_MIB_XFRMOUTSTATEMODEERROR,	/* XfrmOutStateModeError */
+	LINUX_MIB_XFRMOUTSTATEEXPIRED,		/* XfrmOutStateExpired */
+	LINUX_MIB_XFRMOUTPOLBLOCK,		/* XfrmOutPolBlock */
+	LINUX_MIB_XFRMOUTPOLDEAD,		/* XfrmOutPolDead */
+	LINUX_MIB_XFRMOUTPOLERROR,		/* XfrmOutPolError */
+	__LINUX_MIB_XFRMMAX
+};
+
 #endif	/* _LINUX_SNMP_H */
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 9c5793d..f2603c6 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -117,6 +117,11 @@ struct linux_mib {
 	unsigned long	mibs[LINUX_MIB_MAX];
 };
 
+/* Linux Xfrm */
+#define LINUX_MIB_XFRMMAX	__LINUX_MIB_XFRMMAX
+struct linux_xfrm_mib {
+	unsigned long	mibs[LINUX_MIB_XFRMMAX];
+};
 
 /* 
  * FIXME: On x86 and some other CPUs the split into user and softirq parts
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6df8253..551bb78 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -19,6 +19,9 @@
 #include <net/route.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
+#ifdef CONFIG_XFRM_STATISTICS
+#include <net/snmp.h>
+#endif
 
 #define XFRM_PROTO_ESP		50
 #define XFRM_PROTO_AH		51
@@ -34,6 +37,17 @@
 #define MODULE_ALIAS_XFRM_TYPE(family, proto) \
 	MODULE_ALIAS("xfrm-type-" __stringify(family) "-" __stringify(proto))
 
+#ifdef CONFIG_XFRM_STATISTICS
+DECLARE_SNMP_STAT(struct linux_xfrm_mib, xfrm_statistics);
+#define XFRM_INC_STATS(field)		SNMP_INC_STATS(xfrm_statistics, field)
+#define XFRM_INC_STATS_BH(field)	SNMP_INC_STATS_BH(xfrm_statistics, field)
+#define XFRM_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(xfrm_statistics, field)
+#else
+#define XFRM_INC_STATS(field)
+#define XFRM_INC_STATS_BH(field)
+#define XFRM_INC_STATS_USER(field)
+#endif
+
 extern struct sock *xfrm_nl;
 extern u32 sysctl_xfrm_aevent_etime;
 extern u32 sysctl_xfrm_aevent_rseqth;
@@ -1139,6 +1153,10 @@ static inline void xfrm6_fini(void)
 }
 #endif
 
+#ifdef CONFIG_XFRM_STATISTICS
+extern int xfrm_proc_init(void);
+#endif
+
 extern int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*), void *);
 extern struct xfrm_state *xfrm_state_alloc(void);
 extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index 45744a3..332cfb0 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -4,5 +4,6 @@
 
 obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
 		      xfrm_input.o xfrm_output.o xfrm_algo.o
+obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4f823f4..7dcc6c1 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -27,11 +27,19 @@
 #include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
+#ifdef CONFIG_XFRM_STATISTICS
+#include <net/snmp.h>
+#endif
 
 #include "xfrm_hash.h"
 
 int sysctl_xfrm_larval_drop __read_mostly;
 
+#ifdef CONFIG_XFRM_STATISTICS
+DEFINE_SNMP_STAT(struct linux_xfrm_mib, xfrm_statistics) __read_mostly;
+EXPORT_SYMBOL(xfrm_statistics);
+#endif
+
 DEFINE_MUTEX(xfrm_cfg_mutex);
 EXPORT_SYMBOL(xfrm_cfg_mutex);
 
@@ -2258,6 +2266,16 @@ static struct notifier_block xfrm_dev_notifier = {
 	0
 };
 
+#ifdef CONFIG_XFRM_STATISTICS
+static int __init xfrm_statistics_init(void)
+{
+	if (snmp_mib_init((void **)xfrm_statistics,
+			  sizeof(struct linux_xfrm_mib)) < 0)
+		return -ENOMEM;
+	return 0;
+}
+#endif
+
 static void __init xfrm_policy_init(void)
 {
 	unsigned int hmask, sz;
@@ -2294,9 +2312,15 @@ static void __init xfrm_policy_init(void)
 
 void __init xfrm_init(void)
 {
+#ifdef CONFIG_XFRM_STATISTICS
+	xfrm_statistics_init();
+#endif
 	xfrm_state_init();
 	xfrm_policy_init();
 	xfrm_input_init();
+#ifdef CONFIG_XFRM_STATISTICS
+	xfrm_proc_init();
+#endif
 }
 
 #ifdef CONFIG_AUDITSYSCALL
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
new file mode 100644
index 0000000..31d0354
--- /dev/null
+++ b/net/xfrm/xfrm_proc.c
@@ -0,0 +1,96 @@
+/*
+ * xfrm_proc.c
+ *
+ * Copyright (C)2006-2007 USAGI/WIDE Project
+ *
+ * Authors:	Masahide NAKAMURA <nakam@linux-ipv6.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <net/snmp.h>
+#include <net/xfrm.h>
+
+static struct snmp_mib xfrm_mib_list[] = {
+	SNMP_MIB_ITEM("XfrmInError", LINUX_MIB_XFRMINERROR),
+	SNMP_MIB_ITEM("XfrmInBufferError", LINUX_MIB_XFRMINBUFFERERROR),
+	SNMP_MIB_ITEM("XfrmInHdrError", LINUX_MIB_XFRMINHDRERROR),
+	SNMP_MIB_ITEM("XfrmInNoStates", LINUX_MIB_XFRMINNOSTATES),
+	SNMP_MIB_ITEM("XfrmInStateProtoError", LINUX_MIB_XFRMINSTATEPROTOERROR),
+	SNMP_MIB_ITEM("XfrmInStateModeError", LINUX_MIB_XFRMINSTATEMODEERROR),
+	SNMP_MIB_ITEM("XfrmInSeqOutOfWindow", LINUX_MIB_XFRMINSEQOUTOFWINDOW),
+	SNMP_MIB_ITEM("XfrmInStateExpired", LINUX_MIB_XFRMINSTATEEXPIRED),
+	SNMP_MIB_ITEM("XfrmInStateMismatch", LINUX_MIB_XFRMINSTATEMISMATCH),
+	SNMP_MIB_ITEM("XfrmInStateInvalid", LINUX_MIB_XFRMINSTATEINVALID),
+	SNMP_MIB_ITEM("XfrmInTmplMismatch", LINUX_MIB_XFRMINTMPLMISMATCH),
+	SNMP_MIB_ITEM("XfrmInNoPols", LINUX_MIB_XFRMINNOPOLS),
+	SNMP_MIB_ITEM("XfrmInPolBlock", LINUX_MIB_XFRMINPOLBLOCK),
+	SNMP_MIB_ITEM("XfrmInPolError", LINUX_MIB_XFRMINPOLERROR),
+	SNMP_MIB_ITEM("XfrmOutError", LINUX_MIB_XFRMOUTERROR),
+	SNMP_MIB_ITEM("XfrmOutBundleGenError", LINUX_MIB_XFRMOUTBUNDLEGENERROR),
+	SNMP_MIB_ITEM("XfrmOutBundleCheckError", LINUX_MIB_XFRMOUTBUNDLECHECKERROR),
+	SNMP_MIB_ITEM("XfrmOutNoStates", LINUX_MIB_XFRMOUTNOSTATES),
+	SNMP_MIB_ITEM("XfrmOutStateProtoError", LINUX_MIB_XFRMOUTSTATEPROTOERROR),
+	SNMP_MIB_ITEM("XfrmOutStateModeError", LINUX_MIB_XFRMOUTSTATEMODEERROR),
+	SNMP_MIB_ITEM("XfrmOutStateExpired", LINUX_MIB_XFRMOUTSTATEEXPIRED),
+	SNMP_MIB_ITEM("XfrmOutPolBlock", LINUX_MIB_XFRMOUTPOLBLOCK),
+	SNMP_MIB_ITEM("XfrmOutPolDead", LINUX_MIB_XFRMOUTPOLDEAD),
+	SNMP_MIB_ITEM("XfrmOutPolError", LINUX_MIB_XFRMOUTPOLERROR),
+	SNMP_MIB_SENTINEL
+};
+
+static unsigned long
+fold_field(void *mib[], int offt)
+{
+        unsigned long res = 0;
+        int i;
+
+        for_each_possible_cpu(i) {
+                res += *(((unsigned long *)per_cpu_ptr(mib[0], i)) + offt);
+                res += *(((unsigned long *)per_cpu_ptr(mib[1], i)) + offt);
+        }
+        return res;
+}
+
+static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
+{
+	int i;
+	for (i=0; xfrm_mib_list[i].name; i++)
+		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
+			   fold_field((void **)xfrm_statistics,
+				      xfrm_mib_list[i].entry));
+	return 0;
+}
+
+static int xfrm_statistics_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, xfrm_statistics_seq_show, NULL);
+}
+
+static struct file_operations xfrm_statistics_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = xfrm_statistics_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = single_release,
+};
+
+int __init xfrm_proc_init(void)
+{
+	int rc = 0;
+
+	if (!proc_net_fops_create(&init_net, "xfrm_stat", S_IRUGO,
+				  &xfrm_statistics_seq_fops))
+		goto stat_fail;
+
+ out:
+	return rc;
+
+ stat_fail:
+	rc = -ENOMEM;
+	goto out;
+}
-- 
1.4.4.2

