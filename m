From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] iproute2 updates
Date: Fri, 4 Mar 2005 03:35:20 +0100
Message-ID: <20050304023520.GD31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen,

You may pull the following changes from bk://tgr.bkbits.net/iproute2-tgr-fix

 o [NETEM] Fix off by one
 o update local header file copies
 o [NEIGH] print number of probes done so far (statistics mode only)

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/04 02:41:20+01:00 tgraf@suug.ch 
#   [NETEM] Fix off by one
# 
# tc/q_netem.c
#   2005/03/04 02:41:20+01:00 tgraf@suug.ch +1 -1
#   [NETEM] Fix off by one
# 
diff -Nru a/tc/q_netem.c b/tc/q_netem.c
--- a/tc/q_netem.c	2005-03-04 03:21:01 +01:00
+++ b/tc/q_netem.c	2005-03-04 03:21:01 +01:00
@@ -243,7 +243,7 @@
 	memcpy(&qopt, RTA_DATA(opt), sizeof(qopt));
 
 	if (len > 0) {
-		struct rtattr *tb[TCA_NETEM_MAX];
+		struct rtattr *tb[TCA_NETEM_MAX+1];
 		parse_rtattr(tb, TCA_NETEM_MAX, RTA_DATA(opt) + sizeof(qopt),
 			     len);
 		

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/04 02:53:35+01:00 tgraf@suug.ch 
#   update local header file copies
# 
# include/linux/tcp.h
#   2005/03/04 02:53:35+01:00 tgraf@suug.ch +2 -0
#   update local header file copies
# 
# include/linux/pkt_sched.h
#   2005/03/04 02:53:35+01:00 tgraf@suug.ch +27 -7
#   update local header file copies
# 
# include/linux/pkt_cls.h
#   2005/03/04 02:53:35+01:00 tgraf@suug.ch +6 -3
#   update local header file copies
# 
# include/linux/netlink.h
#   2005/03/04 02:53:35+01:00 tgraf@suug.ch +1 -0
#   update local header file copies
# 
# include/linux/gen_stats.h
#   2005/03/04 02:53:35+01:00 tgraf@suug.ch +5 -0
#   update local header file copies
# 
diff -Nru a/include/linux/gen_stats.h b/include/linux/gen_stats.h
--- a/include/linux/gen_stats.h	2005-03-04 03:21:09 +01:00
+++ b/include/linux/gen_stats.h	2005-03-04 03:21:09 +01:00
@@ -14,6 +14,7 @@
 #define TCA_STATS_MAX (__TCA_STATS_MAX - 1)
 
 /**
+ * struct gnet_stats_basic - byte/packet throughput statistics
  * @bytes: number of seen bytes
  * @packets: number of seen packets
  */
@@ -24,6 +25,7 @@
 };
 
 /**
+ * struct gnet_stats_rate_est - rate estimator
  * @bps: current byte rate
  * @pps: current packet rate
  */
@@ -34,10 +36,12 @@
 };
 
 /**
+ * struct gnet_stats_queue - queuing statistics
  * @qlen: queue length
  * @backlog: backlog size of queue
  * @drops: number of dropped packets
  * @requeues: number of requeues
+ * @overlimits: number of enqueues over the limit
  */
 struct gnet_stats_queue
 {
@@ -49,6 +53,7 @@
 };
 
 /**
+ * struct gnet_estimator - rate estimator configuration
  * @interval: sampling period
  * @ewma_log: the log of measurement window weight
  */
diff -Nru a/include/linux/netlink.h b/include/linux/netlink.h
--- a/include/linux/netlink.h	2005-03-04 03:21:09 +01:00
+++ b/include/linux/netlink.h	2005-03-04 03:21:09 +01:00
@@ -16,6 +16,7 @@
 #define NETLINK_ROUTE6		11	/* af_inet6 route comm channel */
 #define NETLINK_IP6_FW		13
 #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
+#define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
 #define NETLINK_TAPBASE		16	/* 16 to 31 are ethertap */
 
 #define MAX_LINKS 32		
diff -Nru a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
--- a/include/linux/pkt_cls.h	2005-03-04 03:21:09 +01:00
+++ b/include/linux/pkt_cls.h	2005-03-04 03:21:09 +01:00
@@ -136,9 +136,9 @@
 
 struct tcf_t
 {
-	__u32   install;
-	__u32   lastuse;
-	__u32   expires;
+	__u64   install;
+	__u64   lastuse;
+	__u64   expires;
 };
 
 struct tc_cnt
@@ -253,6 +253,7 @@
 	TCA_RSVP_SRC,
 	TCA_RSVP_PINFO,
 	TCA_RSVP_POLICE,
+	TCA_RSVP_ACT,
 	__TCA_RSVP_MAX
 };
 
@@ -284,6 +285,7 @@
 	TCA_ROUTE4_FROM,
 	TCA_ROUTE4_IIF,
 	TCA_ROUTE4_POLICE,
+	TCA_ROUTE4_ACT,
 	__TCA_ROUTE4_MAX
 };
 
@@ -315,6 +317,7 @@
 	TCA_TCINDEX_FALL_THROUGH,
 	TCA_TCINDEX_CLASSID,
 	TCA_TCINDEX_POLICE,
+	TCA_TCINDEX_ACT,
 	__TCA_TCINDEX_MAX
 };
 
diff -Nru a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
--- a/include/linux/pkt_sched.h	2005-03-04 03:21:09 +01:00
+++ b/include/linux/pkt_sched.h	2005-03-04 03:21:09 +01:00
@@ -117,8 +117,11 @@
 	TCA_TBF_PARMS,
 	TCA_TBF_RTAB,
 	TCA_TBF_PTAB,
+	__TCA_TBF_MAX,
 };
 
+#define TCA_TBF_MAX (__TCA_TBF_MAX - 1)
+
 
 /* TEQL section */
 
@@ -151,8 +154,11 @@
 	TCA_RED_UNSPEC,
 	TCA_RED_PARMS,
 	TCA_RED_STAB,
+	__TCA_RED_MAX,
 };
 
+#define TCA_RED_MAX (__TCA_RED_MAX - 1)
+
 struct tc_red_qopt
 {
 	__u32		limit;		/* HARD maximal queue length (bytes)	*/
@@ -183,8 +189,11 @@
        TCA_GRED_PARMS,
        TCA_GRED_STAB,
        TCA_GRED_DPS,
+	   __TCA_GRED_MAX,
 };
 
+#define TCA_GRED_MAX (__TCA_GRED_MAX - 1)
+
 #define TCA_SET_OFF TCA_GRED_PARMS
 struct tc_gred_qopt
 {
@@ -249,7 +258,11 @@
 	TCA_HTB_INIT,
 	TCA_HTB_CTAB,
 	TCA_HTB_RTAB,
+	__TCA_HTB_MAX,
 };
+
+#define TCA_HTB_MAX (__TCA_HTB_MAX - 1)
+
 struct tc_htb_xstats
 {
 	__u32 lends;
@@ -287,9 +300,12 @@
 	TCA_HFSC_RSC,
 	TCA_HFSC_FSC,
 	TCA_HFSC_USC,
-	TCA_HFSC_MAX = TCA_HFSC_USC
+	__TCA_HFSC_MAX,
 };
 
+#define TCA_HFSC_MAX (__TCA_HFSC_MAX - 1)
+
+
 /* CBQ section */
 
 #define TC_CBQ_MAXPRIO		8
@@ -370,9 +386,10 @@
 	TCA_CBQ_RATE,
 	TCA_CBQ_RTAB,
 	TCA_CBQ_POLICE,
+	__TCA_CBQ_MAX,
 };
 
-#define TCA_CBQ_MAX	TCA_CBQ_POLICE
+#define TCA_CBQ_MAX	(__TCA_CBQ_MAX - 1)
 
 /* dsmark section */
 
@@ -382,10 +399,11 @@
 	TCA_DSMARK_DEFAULT_INDEX,
 	TCA_DSMARK_SET_TC_INDEX,
 	TCA_DSMARK_MASK,
-	TCA_DSMARK_VALUE
+	TCA_DSMARK_VALUE,
+	__TCA_DSMARK_MAX,
 };
 
-#define TCA_DSMARK_MAX TCA_DSMARK_VALUE
+#define TCA_DSMARK_MAX (__TCA_DSMARK_MAX - 1)
 
 /* ATM  section */
 
@@ -396,10 +414,11 @@
 	TCA_ATM_HDR,		/* LL header */
 	TCA_ATM_EXCESS,		/* excess traffic class (0 for CLP)  */
 	TCA_ATM_ADDR,		/* PVC address (for output only) */
-	TCA_ATM_STATE		/* VC state (ATM_VS_*; for output only) */
+	TCA_ATM_STATE,		/* VC state (ATM_VS_*; for output only) */
+	__TCA_ATM_MAX,
 };
 
-#define TCA_ATM_MAX	TCA_ATM_STATE
+#define TCA_ATM_MAX	(__TCA_ATM_MAX - 1)
 
 /* Network emulator */
 
@@ -408,9 +427,10 @@
 	TCA_NETEM_UNSPEC,
 	TCA_NETEM_CORR,
 	TCA_NETEM_DELAY_DIST,
+	__TCA_NETEM_MAX,
 };
 
-#define TCA_NETEM_MAX	TCA_NETEM_DELAY_DIST
+#define TCA_NETEM_MAX (__TCA_NETEM_MAX - 1)
 
 struct tc_netem_qopt
 {
diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2005-03-04 03:21:09 +01:00
+++ b/include/linux/tcp.h	2005-03-04 03:21:09 +01:00
@@ -186,6 +186,8 @@
 
 	__u32	tcpi_rcv_rtt;
 	__u32	tcpi_rcv_space;
+
+	__u32	tcpi_total_retrans;
 };
 
 #endif	/* _LINUX_TCP_H */


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/04 03:14:42+01:00 tgraf@suug.ch 
#   [NEIGH] print number of probes done so far (statistics mode only)
# 
# ip/ipneigh.c
#   2005/03/04 03:14:42+01:00 tgraf@suug.ch +5 -0
#   print number of probes done in statistics mode
# 
# include/linux/rtnetlink.h
#   2005/03/04 03:14:42+01:00 tgraf@suug.ch +1 -0
#   update local header file copy
# 
diff -Nru a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h	2005-03-04 03:21:15 +01:00
+++ b/include/linux/rtnetlink.h	2005-03-04 03:21:15 +01:00
@@ -446,6 +446,7 @@
 	NDA_DST,
 	NDA_LLADDR,
 	NDA_CACHEINFO,
+	NDA_PROBES,
 	__NDA_MAX
 };
 
diff -Nru a/ip/ipneigh.c b/ip/ipneigh.c
--- a/ip/ipneigh.c	2005-03-04 03:21:15 +01:00
+++ b/ip/ipneigh.c	2005-03-04 03:21:15 +01:00
@@ -287,6 +287,11 @@
 		       ci->ndm_confirmed/hz, ci->ndm_updated/hz);
 	}
 
+	if (tb[NDA_PROBES] && show_stats) {
+		__u32 p = *(__u32 *) RTA_DATA(tb[NDA_PROBES]);
+		fprintf(fp, " probes %u", p);
+	}
+
 	if (r->ndm_state) {
 		int nud = r->ndm_state;
 		fprintf(fp, " ");
