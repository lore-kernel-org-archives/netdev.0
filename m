From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: act: remove headers in include/net/tc_act/
Date: Tue, 14 Jan 2014 17:01:39 -0800
Message-ID: <1389747699-32508-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:60139 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbaAOBBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:01:48 -0500
Received: by mail-pb0-f50.google.com with SMTP id rq2so394381pbb.9
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 17:01:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These headers are not necessary because those definitions in them
are action specific and are not shared for others. Just move them
into the C files.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/tc_act/tc_csum.h    | 15 ---------------
 include/net/tc_act/tc_defact.h  | 14 --------------
 include/net/tc_act/tc_gact.h    | 17 -----------------
 include/net/tc_act/tc_ipt.h     | 17 -----------------
 include/net/tc_act/tc_mirred.h  | 17 -----------------
 include/net/tc_act/tc_nat.h     | 21 ---------------------
 include/net/tc_act/tc_pedit.h   | 15 ---------------
 include/net/tc_act/tc_skbedit.h | 35 -----------------------------------
 net/sched/act_csum.c            | 10 +++++++++-
 net/sched/act_gact.c            | 14 +++++++++++++-
 net/sched/act_ipt.c             | 12 +++++++++++-
 net/sched/act_mirred.c          | 13 ++++++++++++-
 net/sched/act_nat.c             | 17 ++++++++++++++++-
 net/sched/act_pedit.c           | 11 ++++++++++-
 net/sched/act_simple.c          | 10 +++++++++-
 net/sched/act_skbedit.c         | 13 ++++++++++++-
 16 files changed, 92 insertions(+), 159 deletions(-)
 delete mode 100644 include/net/tc_act/tc_csum.h
 delete mode 100644 include/net/tc_act/tc_defact.h
 delete mode 100644 include/net/tc_act/tc_gact.h
 delete mode 100644 include/net/tc_act/tc_ipt.h
 delete mode 100644 include/net/tc_act/tc_mirred.h
 delete mode 100644 include/net/tc_act/tc_nat.h
 delete mode 100644 include/net/tc_act/tc_pedit.h
 delete mode 100644 include/net/tc_act/tc_skbedit.h

diff --git a/include/net/tc_act/tc_csum.h b/include/net/tc_act/tc_csum.h
deleted file mode 100644
index 9e8710b..0000000
--- a/include/net/tc_act/tc_csum.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef __NET_TC_CSUM_H
-#define __NET_TC_CSUM_H
-
-#include <linux/types.h>
-#include <net/act_api.h>
-
-struct tcf_csum {
-	struct tcf_common common;
-
-	u32 update_flags;
-};
-#define to_tcf_csum(pc) \
-	container_of(pc,struct tcf_csum,common)
-
-#endif /* __NET_TC_CSUM_H */
diff --git a/include/net/tc_act/tc_defact.h b/include/net/tc_act/tc_defact.h
deleted file mode 100644
index 65f024b..0000000
--- a/include/net/tc_act/tc_defact.h
+++ /dev/null
@@ -1,14 +0,0 @@
-#ifndef __NET_TC_DEF_H
-#define __NET_TC_DEF_H
-
-#include <net/act_api.h>
-
-struct tcf_defact {
-	struct tcf_common	common;
-	u32     		tcfd_datalen;
-	void    		*tcfd_defdata;
-};
-#define to_defact(pc) \
-	container_of(pc, struct tcf_defact, common)
-
-#endif /* __NET_TC_DEF_H */
diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
deleted file mode 100644
index 9e3f676..0000000
--- a/include/net/tc_act/tc_gact.h
+++ /dev/null
@@ -1,17 +0,0 @@
-#ifndef __NET_TC_GACT_H
-#define __NET_TC_GACT_H
-
-#include <net/act_api.h>
-
-struct tcf_gact {
-	struct tcf_common	common;
-#ifdef CONFIG_GACT_PROB
-        u16			tcfg_ptype;
-        u16			tcfg_pval;
-        int			tcfg_paction;
-#endif
-};
-#define to_gact(pc) \
-	container_of(pc, struct tcf_gact, common)
-
-#endif /* __NET_TC_GACT_H */
diff --git a/include/net/tc_act/tc_ipt.h b/include/net/tc_act/tc_ipt.h
deleted file mode 100644
index f7d25df..0000000
--- a/include/net/tc_act/tc_ipt.h
+++ /dev/null
@@ -1,17 +0,0 @@
-#ifndef __NET_TC_IPT_H
-#define __NET_TC_IPT_H
-
-#include <net/act_api.h>
-
-struct xt_entry_target;
-
-struct tcf_ipt {
-	struct tcf_common	common;
-	u32			tcfi_hook;
-	char			*tcfi_tname;
-	struct xt_entry_target	*tcfi_t;
-};
-#define to_ipt(pc) \
-	container_of(pc, struct tcf_ipt, common)
-
-#endif /* __NET_TC_IPT_H */
diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
deleted file mode 100644
index cfe2943..0000000
--- a/include/net/tc_act/tc_mirred.h
+++ /dev/null
@@ -1,17 +0,0 @@
-#ifndef __NET_TC_MIR_H
-#define __NET_TC_MIR_H
-
-#include <net/act_api.h>
-
-struct tcf_mirred {
-	struct tcf_common	common;
-	int			tcfm_eaction;
-	int			tcfm_ifindex;
-	int			tcfm_ok_push;
-	struct net_device	*tcfm_dev;
-	struct list_head	tcfm_list;
-};
-#define to_mirred(pc) \
-	container_of(pc, struct tcf_mirred, common)
-
-#endif /* __NET_TC_MIR_H */
diff --git a/include/net/tc_act/tc_nat.h b/include/net/tc_act/tc_nat.h
deleted file mode 100644
index 4a691f3..0000000
--- a/include/net/tc_act/tc_nat.h
+++ /dev/null
@@ -1,21 +0,0 @@
-#ifndef __NET_TC_NAT_H
-#define __NET_TC_NAT_H
-
-#include <linux/types.h>
-#include <net/act_api.h>
-
-struct tcf_nat {
-	struct tcf_common common;
-
-	__be32 old_addr;
-	__be32 new_addr;
-	__be32 mask;
-	u32 flags;
-};
-
-static inline struct tcf_nat *to_tcf_nat(struct tcf_common *pc)
-{
-	return container_of(pc, struct tcf_nat, common);
-}
-
-#endif /* __NET_TC_NAT_H */
diff --git a/include/net/tc_act/tc_pedit.h b/include/net/tc_act/tc_pedit.h
deleted file mode 100644
index e6f6e15..0000000
--- a/include/net/tc_act/tc_pedit.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef __NET_TC_PED_H
-#define __NET_TC_PED_H
-
-#include <net/act_api.h>
-
-struct tcf_pedit {
-	struct tcf_common	common;
-	unsigned char		tcfp_nkeys;
-	unsigned char		tcfp_flags;
-	struct tc_pedit_key	*tcfp_keys;
-};
-#define to_pedit(pc) \
-	container_of(pc, struct tcf_pedit, common)
-
-#endif /* __NET_TC_PED_H */
diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
deleted file mode 100644
index dd5d86f..0000000
--- a/include/net/tc_act/tc_skbedit.h
+++ /dev/null
@@ -1,35 +0,0 @@
-/*
- * Copyright (c) 2008, Intel Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms and conditions of the GNU General Public License,
- * version 2, as published by the Free Software Foundation.
- *
- * This program is distributed in the hope it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, see <http://www.gnu.org/licenses/>.
- *
- * Author: Alexander Duyck <alexander.h.duyck@intel.com>
- */
-
-#ifndef __NET_TC_SKBEDIT_H
-#define __NET_TC_SKBEDIT_H
-
-#include <net/act_api.h>
-
-struct tcf_skbedit {
-	struct tcf_common	common;
-	u32			flags;
-	u32     		priority;
-	u32     		mark;
-	u16			queue_mapping;
-	/* XXX: 16-bit pad here? */
-};
-#define to_skbedit(pc) \
-	container_of(pc, struct tcf_skbedit, common)
-
-#endif /* __NET_TC_SKBEDIT_H */
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index ee28e1c..c0da35b 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -34,7 +34,15 @@
 #include <net/act_api.h>
 
 #include <linux/tc_act/tc_csum.h>
-#include <net/tc_act/tc_csum.h>
+#include <linux/types.h>
+
+struct tcf_csum {
+	struct tcf_common common;
+
+	u32 update_flags;
+};
+#define to_tcf_csum(pc) \
+	container_of(pc,struct tcf_csum,common)
 
 #define CSUM_TAB_MASK 15
 static struct tcf_hashinfo csum_hash_info;
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index f26e6b8..c5e7491 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -21,7 +21,19 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_gact.h>
-#include <net/tc_act/tc_gact.h>
+
+#include <net/act_api.h>
+
+struct tcf_gact {
+	struct tcf_common	common;
+#ifdef CONFIG_GACT_PROB
+        u16			tcfg_ptype;
+        u16			tcfg_pval;
+        int			tcfg_paction;
+#endif
+};
+#define to_gact(pc) \
+	container_of(pc, struct tcf_gact, common)
 
 #define GACT_TAB_MASK	15
 static struct tcf_hashinfo gact_hash_info;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 484bd19..469c066 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -23,10 +23,20 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_ipt.h>
-#include <net/tc_act/tc_ipt.h>
 
+#include <net/act_api.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 
+struct xt_entry_target;
+
+struct tcf_ipt {
+	struct tcf_common	common;
+	u32			tcfi_hook;
+	char			*tcfi_tname;
+	struct xt_entry_target	*tcfi_t;
+};
+#define to_ipt(pc) \
+	container_of(pc, struct tcf_ipt, common)
 
 #define IPT_TAB_MASK     15
 static struct tcf_hashinfo ipt_hash_info;
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 5d05b57..0024525 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -25,9 +25,20 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_mirred.h>
-#include <net/tc_act/tc_mirred.h>
 
 #include <linux/if_arp.h>
+#include <net/act_api.h>
+
+struct tcf_mirred {
+	struct tcf_common	common;
+	int			tcfm_eaction;
+	int			tcfm_ifindex;
+	int			tcfm_ok_push;
+	struct net_device	*tcfm_dev;
+	struct list_head	tcfm_list;
+};
+#define to_mirred(pc) \
+	container_of(pc, struct tcf_mirred, common)
 
 #define MIRRED_TAB_MASK     7
 static LIST_HEAD(mirred_list);
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index a49fa23..4039399 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -24,10 +24,25 @@
 #include <net/icmp.h>
 #include <net/ip.h>
 #include <net/netlink.h>
-#include <net/tc_act/tc_nat.h>
 #include <net/tcp.h>
 #include <net/udp.h>
 
+#include <linux/types.h>
+#include <net/act_api.h>
+
+struct tcf_nat {
+	struct tcf_common common;
+
+	__be32 old_addr;
+	__be32 new_addr;
+	__be32 mask;
+	u32 flags;
+};
+
+static inline struct tcf_nat *to_tcf_nat(struct tcf_common *pc)
+{
+	return container_of(pc, struct tcf_nat, common);
+}
 
 #define NAT_TAB_MASK	15
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index f361e4e..9222ac7 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -21,7 +21,16 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_pedit.h>
-#include <net/tc_act/tc_pedit.h>
+#include <net/act_api.h>
+
+struct tcf_pedit {
+	struct tcf_common	common;
+	unsigned char		tcfp_nkeys;
+	unsigned char		tcfp_flags;
+	struct tc_pedit_key	*tcfp_keys;
+};
+#define to_pedit(pc) \
+	container_of(pc, struct tcf_pedit, common)
 
 #define PEDIT_TAB_MASK	15
 
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index f7d5406..8f695bb 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -22,7 +22,15 @@
 #define TCA_ACT_SIMP 22
 
 #include <linux/tc_act/tc_defact.h>
-#include <net/tc_act/tc_defact.h>
+#include <net/act_api.h>
+
+struct tcf_defact {
+	struct tcf_common	common;
+	u32     		tcfd_datalen;
+	void    		*tcfd_defdata;
+};
+#define to_defact(pc) \
+	container_of(pc, struct tcf_defact, common)
 
 #define SIMP_TAB_MASK     7
 static struct tcf_hashinfo simp_hash_info;
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 74af461..b9d27e7 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -25,7 +25,18 @@
 #include <net/pkt_sched.h>
 
 #include <linux/tc_act/tc_skbedit.h>
-#include <net/tc_act/tc_skbedit.h>
+#include <net/act_api.h>
+
+struct tcf_skbedit {
+	struct tcf_common	common;
+	u32			flags;
+	u32     		priority;
+	u32     		mark;
+	u16			queue_mapping;
+	/* XXX: 16-bit pad here? */
+};
+#define to_skbedit(pc) \
+	container_of(pc, struct tcf_skbedit, common)
 
 #define SKBEDIT_TAB_MASK     15
 static struct tcf_hashinfo skbedit_hash_info;
-- 
1.8.3.1
