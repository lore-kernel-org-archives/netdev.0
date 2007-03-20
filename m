From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 4/5] [NETLINK]: Use nlmsg_trim() where appropriate
Date: Mon, 19 Mar 2007 22:39:44 -0300
Message-ID: <20070320013944.GJ17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:36826 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbXCTBju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 21:39:50 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1497744wxd
        for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 18:39:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/netlink.h                |    2 +-
 net/core/wireless.c                  |    2 +-
 net/decnet/dn_route.c                |    3 ++-
 net/decnet/dn_table.c                |    3 ++-
 net/ipv4/inet_diag.c                 |    7 ++++---
 net/ipv4/ipmr.c                      |    3 ++-
 net/netfilter/nf_conntrack_netlink.c |    5 +++--
 net/sched/act_api.c                  |   17 +++++++++--------
 net/sched/act_gact.c                 |    3 ++-
 net/sched/act_ipt.c                  |    3 ++-
 net/sched/act_mirred.c               |    3 ++-
 net/sched/act_pedit.c                |    3 ++-
 net/sched/act_police.c               |    9 +++++----
 net/sched/act_simple.c               |    3 ++-
 net/sched/cls_api.c                  |    4 +++-
 net/sched/cls_basic.c                |    3 ++-
 net/sched/cls_fw.c                   |    3 ++-
 net/sched/cls_route.c                |    3 ++-
 net/sched/cls_rsvp.c                 |    1 +
 net/sched/cls_rsvp.h                 |    2 +-
 net/sched/cls_rsvp6.c                |    1 +
 net/sched/cls_tcindex.c              |    3 ++-
 net/sched/cls_u32.c                  |    3 ++-
 net/sched/sch_api.c                  |    5 +++--
 net/sched/sch_atm.c                  |    3 ++-
 net/sched/sch_cbq.c                  |   17 +++++++++--------
 net/sched/sch_hfsc.c                 |    5 +++--
 net/sched/sch_htb.c                  |    5 +++--
 net/sched/sch_ingress.c              |    3 ++-
 net/sched/sch_netem.c                |    3 ++-
 net/sched/sch_prio.c                 |    3 ++-
 net/sched/sch_sfq.c                  |    3 ++-
 net/sched/sch_tbf.c                  |    3 ++-
 net/xfrm/xfrm_user.c                 |   16 ++++++++--------
 34 files changed, 93 insertions(+), 62 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 2c7ab10..510ca7f 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -548,7 +548,7 @@ static inline void *nlmsg_get_pos(struct sk_buff *skb)
  *
  * Trims the message to the provided mark. Returns -1.
  */
-static inline int nlmsg_trim(struct sk_buff *skb, void *mark)
+static inline int nlmsg_trim(struct sk_buff *skb, const void *mark)
 {
 	if (mark)
 		skb_trim(skb, (unsigned char *) mark - skb->data);
diff --git a/net/core/wireless.c b/net/core/wireless.c
index 1346287..472a6f2 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -1939,7 +1939,7 @@ static inline int rtnetlink_fill_iwinfo(struct sk_buff *	skb,
 
 nlmsg_failure:
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 9678b09..2ae35ef 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -77,6 +77,7 @@
 #include <linux/rcupdate.h>
 #include <linux/times.h>
 #include <asm/errno.h>
+#include <net/netlink.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
 #include <net/flow.h>
@@ -1514,7 +1515,7 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 
 nlmsg_failure:
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 544c455..d6615c9 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -28,6 +28,7 @@
 #include <asm/uaccess.h>
 #include <linux/route.h> /* RTF_xxx */
 #include <net/neighbour.h>
+#include <net/netlink.h>
 #include <net/dst.h>
 #include <net/flow.h>
 #include <net/fib_rules.h>
@@ -349,7 +350,7 @@ static int dn_fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 
 nlmsg_failure:
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -EMSGSIZE;
 }
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 238999e..62c2e9f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -27,6 +27,7 @@
 #include <net/inet_hashtables.h>
 #include <net/inet_timewait_sock.h>
 #include <net/inet6_hashtables.h>
+#include <net/netlink.h>
 
 #include <linux/inet.h>
 #include <linux/stddef.h>
@@ -152,7 +153,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 
 rtattr_failure:
 nlmsg_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -EMSGSIZE;
 }
 
@@ -208,7 +209,7 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - previous_tail;
 	return skb->len;
 nlmsg_failure:
-	skb_trim(skb, previous_tail - skb->data);
+	nlmsg_trim(skb, previous_tail);
 	return -EMSGSIZE;
 }
 
@@ -579,7 +580,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	return skb->len;
 
 nlmsg_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index ea0a491..48027df 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -62,6 +62,7 @@
 #include <linux/netfilter_ipv4.h>
 #include <net/ipip.h>
 #include <net/checksum.h>
+#include <net/netlink.h>
 
 #if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
 #define CONFIG_IP_PIMSM	1
@@ -1570,7 +1571,7 @@ ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm)
 	return 1;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -EMSGSIZE;
 }
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 442300c..76f11f3 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -33,6 +33,7 @@
 #include <linux/notifier.h>
 
 #include <linux/netfilter.h>
+#include <net/netlink.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_expect.h>
@@ -306,7 +307,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 
 nlmsg_failure:
 nfattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1169,7 +1170,7 @@ ctnetlink_exp_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 
 nlmsg_failure:
 nfattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 28326fb..f002f74 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -31,6 +31,7 @@
 #include <net/sock.h>
 #include <net/sch_generic.h>
 #include <net/act_api.h>
+#include <net/netlink.h>
 
 void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 {
@@ -98,7 +99,7 @@ static int tcf_dump_walker(struct sk_buff *skb, struct netlink_callback *cb,
 			err = tcf_action_dump_1(skb, a, 0, 0);
 			if (err < 0) {
 				index--;
-				skb_trim(skb, (u8*)r - skb->data);
+				nlmsg_trim(skb, r);
 				goto done;
 			}
 			r->rta_len = skb_tail_pointer(skb) - (u8 *)r;
@@ -114,7 +115,7 @@ done:
 	return n_i;
 
 rtattr_failure:
-	skb_trim(skb, (u8*)r - skb->data);
+	nlmsg_trim(skb, r);
 	goto done;
 }
 
@@ -144,7 +145,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a,
 
 	return n_i;
 rtattr_failure:
-	skb_trim(skb, (u8*)r - skb->data);
+	nlmsg_trim(skb, r);
 	return -EINVAL;
 }
 
@@ -440,7 +441,7 @@ tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	}
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -467,7 +468,7 @@ tcf_action_dump(struct sk_buff *skb, struct tc_action *act, int bind, int ref)
 rtattr_failure:
 	err = -EINVAL;
 errout:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return err;
 }
 
@@ -658,7 +659,7 @@ tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
 
 rtattr_failure:
 nlmsg_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1059,7 +1060,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 		x->rta_len = skb_tail_pointer(skb) - (u8 *)x;
 		ret = skb->len;
 	} else
-		skb_trim(skb, (u8*)x - skb->data);
+		nlmsg_trim(skb, x);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	if (NETLINK_CB(cb->skb).pid && ret)
@@ -1070,7 +1071,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 rtattr_failure:
 nlmsg_failure:
 	module_put(a_o->owner);
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return skb->len;
 }
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index aad748b..7517f37 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -28,6 +28,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
+#include <net/netlink.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_gact.h>
@@ -181,7 +182,7 @@ static int tcf_gact_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 2ccfd5b..00b05f4 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -30,6 +30,7 @@
 #include <linux/init.h>
 #include <linux/proc_fs.h>
 #include <linux/kmod.h>
+#include <net/netlink.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_ipt.h>
@@ -277,7 +278,7 @@ static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	kfree(t);
 	return -1;
 }
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index f3121c9..dee78ad 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -30,6 +30,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
+#include <net/netlink.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_mirred.h>
@@ -225,7 +226,7 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, i
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index d654cea..45b3cda 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -27,6 +27,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
+#include <net/netlink.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_pedit.h>
@@ -226,7 +227,7 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	kfree(opt);
 	return -1;
 }
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 068b237..0a5679e 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -30,6 +30,7 @@
 #include <linux/init.h>
 #include <net/sock.h>
 #include <net/act_api.h>
+#include <net/netlink.h>
 
 #define L2T(p,L)   ((p)->tcfp_R_tab->data[(L)>>(p)->tcfp_R_tab->rate.cell_log])
 #define L2T_P(p,L) ((p)->tcfp_P_tab->data[(L)>>(p)->tcfp_P_tab->rate.cell_log])
@@ -88,7 +89,7 @@ static int tcf_act_police_walker(struct sk_buff *skb, struct netlink_callback *c
 				err = tcf_action_dump_1(skb, a, 0, 0);
 			if (err < 0) {
 				index--;
-				skb_trim(skb, (u8*)r - skb->data);
+				nlmsg_trim(skb, r);
 				goto done;
 			}
 			r->rta_len = skb_tail_pointer(skb) - (u8 *)r;
@@ -102,7 +103,7 @@ done:
 	return n_i;
 
 rtattr_failure:
-	skb_trim(skb, (u8*)r - skb->data);
+	nlmsg_trim(skb, r);
 	goto done;
 }
 #endif
@@ -355,7 +356,7 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -598,7 +599,7 @@ int tcf_police_dump(struct sk_buff *skb, struct tcf_police *police)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index ecbcfa5..36e1eda 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -16,6 +16,7 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 
 #define TCA_ACT_SIMP 22
@@ -173,7 +174,7 @@ static inline int tcf_simp_dump(struct sk_buff *skb, struct tc_action *a,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 84231ba..3d0a6cd 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -32,6 +32,8 @@
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
+#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
@@ -345,7 +347,7 @@ tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp, unsigned long fh,
 
 nlmsg_failure:
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index a81a506..a05c32f 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -17,6 +17,7 @@
 #include <linux/errno.h>
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
+#include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
@@ -268,7 +269,7 @@ static int basic_dump(struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index f5f3558..bbec4a0 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -38,6 +38,7 @@
 #include <linux/notifier.h>
 #include <linux/netfilter.h>
 #include <net/ip.h>
+#include <net/netlink.h>
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
@@ -382,7 +383,7 @@ static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 04d934b..c304dc6 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -28,6 +28,7 @@
 #include <linux/etherdevice.h>
 #include <linux/notifier.h>
 #include <net/ip.h>
+#include <net/netlink.h>
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
@@ -599,7 +600,7 @@ static int route4_dump(struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/cls_rsvp.c b/net/sched/cls_rsvp.c
index 1d4a1fb..0a683c0 100644
--- a/net/sched/cls_rsvp.c
+++ b/net/sched/cls_rsvp.c
@@ -31,6 +31,7 @@
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
+#include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 87ed6f3..22f9ede 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -630,7 +630,7 @@ static int rsvp_dump(struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/cls_rsvp6.c b/net/sched/cls_rsvp6.c
index a2979d8..93b6abe 100644
--- a/net/sched/cls_rsvp6.c
+++ b/net/sched/cls_rsvp6.c
@@ -34,6 +34,7 @@
 #include <net/sock.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
+#include <net/netlink.h>
 
 #define RSVP_DST_LEN	4
 #define RSVP_ID		"rsvp6"
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index c9efac7..ec140a8 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -12,6 +12,7 @@
 #include <linux/netdevice.h>
 #include <net/ip.h>
 #include <net/act_api.h>
+#include <net/netlink.h>
 #include <net/pkt_cls.h>
 #include <net/route.h>
 
@@ -495,7 +496,7 @@ static int tcindex_dump(struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index fa11bb7..62e1deb 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -50,6 +50,7 @@
 #include <linux/notifier.h>
 #include <linux/rtnetlink.h>
 #include <net/ip.h>
+#include <net/netlink.h>
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
@@ -772,7 +773,7 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7482a95..0b9abea 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -36,6 +36,7 @@
 #include <linux/bitops.h>
 #include <linux/hrtimer.h>
 
+#include <net/netlink.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 
@@ -852,7 +853,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 
 nlmsg_failure:
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1081,7 +1082,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 
 nlmsg_failure:
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 1d7bb16..0cc3c9b 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -14,6 +14,7 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/file.h> /* for fput */
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/sock.h>
 
@@ -665,7 +666,7 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb,b-skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 static int
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index be98a01..dcd9c31 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -29,6 +29,7 @@
 #include <linux/etherdevice.h>
 #include <linux/notifier.h>
 #include <net/ip.h>
+#include <net/netlink.h>
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
@@ -1471,7 +1472,7 @@ static __inline__ int cbq_dump_rate(struct sk_buff *skb, struct cbq_class *cl)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1496,7 +1497,7 @@ static __inline__ int cbq_dump_lss(struct sk_buff *skb, struct cbq_class *cl)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1514,7 +1515,7 @@ static __inline__ int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1531,7 +1532,7 @@ static __inline__ int cbq_dump_ovl(struct sk_buff *skb, struct cbq_class *cl)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1549,7 +1550,7 @@ static __inline__ int cbq_dump_fopt(struct sk_buff *skb, struct cbq_class *cl)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1568,7 +1569,7 @@ static __inline__ int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 #endif
@@ -1601,7 +1602,7 @@ static int cbq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1637,7 +1638,7 @@ cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index ac76276..79126e5 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -65,6 +65,7 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <linux/pkt_sched.h>
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
 #include <asm/system.h>
@@ -1376,7 +1377,7 @@ hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
 	return skb->len;
 
  rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1582,7 +1583,7 @@ hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 	return skb->len;
 
  rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index af4ecba..d265ac4 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -50,6 +50,7 @@
 #include <linux/skbuff.h>
 #include <linux/list.h>
 #include <linux/compiler.h>
+#include <net/netlink.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <linux/rbtree.h>
@@ -1128,7 +1129,7 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	return skb->len;
 rtattr_failure:
 	spin_unlock_bh(&sch->dev->queue_lock);
-	skb_trim(skb, skb_tail_pointer(skb) - skb->data);
+	nlmsg_trim(skb, skb_tail_pointer(skb));
 	return -1;
 }
 
@@ -1164,7 +1165,7 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	return skb->len;
 rtattr_failure:
 	spin_unlock_bh(&sch->dev->queue_lock);
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index d19f407..f63d5c6 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -16,6 +16,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter.h>
 #include <linux/smp.h>
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
@@ -371,7 +372,7 @@ static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 2a9b1e4..4818da5 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -22,6 +22,7 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 
+#include <net/netlink.h>
 #include <net/pkt_sched.h>
 
 #define VERSION "1.2"
@@ -616,7 +617,7 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 5b37110..f139963 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -32,6 +32,7 @@
 #include <net/ip.h>
 #include <net/route.h>
 #include <linux/skbuff.h>
+#include <net/netlink.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 
@@ -280,7 +281,7 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index a511ba8..96dfdf7 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -30,6 +30,7 @@
 #include <linux/notifier.h>
 #include <linux/init.h>
 #include <net/ip.h>
+#include <net/netlink.h>
 #include <linux/ipv6.h>
 #include <net/route.h>
 #include <linux/skbuff.h>
@@ -476,7 +477,7 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 2318955..626ce96 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -32,6 +32,7 @@
 #include <linux/etherdevice.h>
 #include <linux/notifier.h>
 #include <net/ip.h>
+#include <net/netlink.h>
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
@@ -408,7 +409,7 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 	return skb->len;
 
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 5a0c38a..699a7e0 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -629,7 +629,7 @@ out:
 
 nlmsg_failure:
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1183,7 +1183,7 @@ out:
 	return 0;
 
 nlmsg_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1368,7 +1368,7 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 
 rtattr_failure:
 nlmsg_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1768,7 +1768,7 @@ static int build_migrate(struct sk_buff *skb, struct xfrm_migrate *m,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 nlmsg_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -1957,7 +1957,7 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 	return skb->len;
 
 nlmsg_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -2158,7 +2158,7 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 	return skb->len;
 
 nlmsg_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -2269,7 +2269,7 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 	return skb->len;
 
 nlmsg_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
@@ -2428,7 +2428,7 @@ static int build_report(struct sk_buff *skb, u8 proto,
 
 nlmsg_failure:
 rtattr_failure:
-	skb_trim(skb, b - skb->data);
+	nlmsg_trim(skb, b);
 	return -1;
 }
 
-- 
1.5.0.3

