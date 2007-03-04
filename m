From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPROUTE 05/08]: Replace "usec" by "time" in function names
Date: Sun,  4 Mar 2007 20:15:00 +0100 (MET)
Message-ID: <20070304191409.22838.6268.sendpatchset@localhost.localdomain>
References: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61736 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbXCDTPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 14:15:01 -0500
In-Reply-To: <20070304191402.22838.91224.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Replace "usec" by "time" in function names

Rename functions containing "usec" since they don't necessarily return
usec units anymore.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c2cf24282b2a051942b18fbf894a9c1b490d925c
tree 128aa960a599aee0725d723b621db651e02ffa74
parent d81b168f4017e45343cdd723e653401058f728e9
author Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 03 Mar 2007 20:30:50 +0100

 tc/m_estimator.c |    4 ++--
 tc/q_cbq.c       |    6 +++---
 tc/q_hfsc.c      |    6 +++---
 tc/q_netem.c     |    8 ++++----
 tc/q_tbf.c       |    8 ++++----
 tc/tc_cbq.c      |    4 ++--
 tc/tc_core.c     |   14 +++++++-------
 tc/tc_core.h     |    6 +++---
 tc/tc_util.c     |   14 +++++++-------
 tc/tc_util.h     |    6 +++---
 10 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/tc/m_estimator.c b/tc/m_estimator.c
index d931551..a9e5dbc 100644
--- a/tc/m_estimator.c
+++ b/tc/m_estimator.c
@@ -45,12 +45,12 @@ int parse_estimator(int *p_argc, char **
 		duparg("estimator", *argv);
 	if (matches(*argv, "help") == 0)
 		est_help();
-	if (get_usecs(&A, *argv))
+	if (get_time(&A, *argv))
 		invarg("estimator", "invalid estimator interval");
 	NEXT_ARG();
 	if (matches(*argv, "help") == 0)
 		est_help();
-	if (get_usecs(&time_const, *argv))
+	if (get_time(&time_const, *argv))
 		invarg("estimator", "invalid estimator time constant");
 	if (tc_setup_estimator(A, time_const, est) < 0) {
 		fprintf(stderr, "Error: estimator parameters are out of range.\n");
diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index 0000a56..913b26a 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -500,17 +500,17 @@ static int cbq_print_opt(struct qdisc_ut
 	if (lss && show_details) {
 		fprintf(f, "\nlevel %u ewma %u avpkt %ub ", lss->level, lss->ewma_log, lss->avpkt);
 		if (lss->maxidle) {
-			fprintf(f, "maxidle %luus ", tc_core_tick2usec(lss->maxidle>>lss->ewma_log));
+			fprintf(f, "maxidle %luus ", tc_core_tick2time(lss->maxidle>>lss->ewma_log));
 			if (show_raw)
 				fprintf(f, "[%08x] ", lss->maxidle);
 		}
 		if (lss->minidle!=0x7fffffff) {
-			fprintf(f, "minidle %luus ", tc_core_tick2usec(lss->minidle>>lss->ewma_log));
+			fprintf(f, "minidle %luus ", tc_core_tick2time(lss->minidle>>lss->ewma_log));
 			if (show_raw)
 				fprintf(f, "[%08x] ", lss->minidle);
 		}
 		if (lss->offtime) {
-			fprintf(f, "offtime %luus ", tc_core_tick2usec(lss->offtime));
+			fprintf(f, "offtime %luus ", tc_core_tick2time(lss->offtime));
 			if (show_raw)
 				fprintf(f, "[%08x] ", lss->offtime);
 		}
diff --git a/tc/q_hfsc.c b/tc/q_hfsc.c
index f7a30f2..b190c71 100644
--- a/tc/q_hfsc.c
+++ b/tc/q_hfsc.c
@@ -226,7 +226,7 @@ hfsc_print_sc(FILE *f, char *name, struc
 
 	fprintf(f, "%s ", name);
 	fprintf(f, "m1 %s ", sprint_rate(sc->m1, b1));
-	fprintf(f, "d %s ", sprint_usecs(tc_core_ktime2time(sc->d), b1));
+	fprintf(f, "d %s ", sprint_time(tc_core_ktime2time(sc->d), b1));
 	fprintf(f, "m2 %s ", sprint_rate(sc->m2, b1));
 }
 
@@ -303,7 +303,7 @@ hfsc_get_sc1(int *argcp, char ***argvp, 
 
 	if (matches(*argv, "d") == 0) {
 		NEXT_ARG();
-		if (get_usecs(&d, *argv) < 0) {
+		if (get_time(&d, *argv) < 0) {
 			explain1("d");
 			return -1;
 		}
@@ -346,7 +346,7 @@ hfsc_get_sc2(int *argcp, char ***argvp, 
 
 	if (matches(*argv, "dmax") == 0) {
 		NEXT_ARG();
-		if (get_usecs(&dmax, *argv) < 0) {
+		if (get_time(&dmax, *argv) < 0) {
 			explain1("dmax");
 			return -1;
 		}
diff --git a/tc/q_netem.c b/tc/q_netem.c
index cfd1799..6035c4f 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -108,15 +108,15 @@ static int get_ticks(__u32 *ticks, const
 {
 	unsigned t;
 
-	if(get_usecs(&t, str))
+	if(get_time(&t, str))
 		return -1;
 
-	if (tc_core_usec2big(t)) {
-		fprintf(stderr, "Illegal %d usecs (too large)\n", t);
+	if (tc_core_time2big(t)) {
+		fprintf(stderr, "Illegal %u time (too large)\n", t);
 		return -1;
 	}
 
-	*ticks = tc_core_usec2tick(t);
+	*ticks = tc_core_time2tick(t);
 	return 0;
 }
 
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index a102696..1fc05f4 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -67,7 +67,7 @@ static int tbf_parse_opt(struct qdisc_ut
 				fprintf(stderr, "Double \"limit/latency\" spec\n");
 				return -1;
 			}
-			if (get_usecs(&latency, *argv)) {
+			if (get_time(&latency, *argv)) {
 				explain1("latency");
 				return -1;
 			}
@@ -245,13 +245,13 @@ static int tbf_print_opt(struct qdisc_ut
 	if (show_raw)
 		fprintf(f, "limit %s ", sprint_size(qopt->limit, b1));
 
-	latency = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->rate.rate) - tc_core_tick2usec(qopt->buffer);
+	latency = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->rate.rate) - tc_core_tick2time(qopt->buffer);
 	if (qopt->peakrate.rate) {
-		double lat2 = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->peakrate.rate) - tc_core_tick2usec(qopt->mtu);
+		double lat2 = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->peakrate.rate) - tc_core_tick2time(qopt->mtu);
 		if (lat2 > latency)
 			latency = lat2;
 	}
-	fprintf(f, "lat %s ", sprint_usecs(latency, b1));
+	fprintf(f, "lat %s ", sprint_time(latency, b1));
 
 	return 0;
 }
diff --git a/tc/tc_cbq.c b/tc/tc_cbq.c
index c7b3a2d..0bb262e 100644
--- a/tc/tc_cbq.c
+++ b/tc/tc_cbq.c
@@ -38,7 +38,7 @@ unsigned tc_cbq_calc_maxidle(unsigned bn
 		if (vxmt > maxidle)
 			maxidle = vxmt;
 	}
-	return tc_core_usec2tick(maxidle*(1<<ewma_log)*TIME_UNITS_PER_SEC);
+	return tc_core_time2tick(maxidle*(1<<ewma_log)*TIME_UNITS_PER_SEC);
 }
 
 unsigned tc_cbq_calc_offtime(unsigned bndw, unsigned rate, unsigned avpkt,
@@ -53,5 +53,5 @@ unsigned tc_cbq_calc_offtime(unsigned bn
 		offtime *= pow(g, -(double)minburst) - 1;
 	else
 		offtime *= 1 + (pow(g, -(double)(minburst-1)) - 1)/(1-g);
-	return tc_core_usec2tick(offtime*TIME_UNITS_PER_SEC);
+	return tc_core_time2tick(offtime*TIME_UNITS_PER_SEC);
 }
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 07dc4ba..e27254e 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -27,21 +27,21 @@ static __u32 t2us=1;
 static __u32 us2t=1;
 static double tick_in_usec = 1;
 
-int tc_core_usec2big(long usec)
+int tc_core_time2big(long time)
 {
-	__u64 t = usec;
+	__u64 t = time;
 
 	t *= tick_in_usec;
 	return (t >> 32) != 0;
 }
 
 
-long tc_core_usec2tick(long usec)
+long tc_core_time2tick(long time)
 {
-	return usec*tick_in_usec;
+	return time*tick_in_usec;
 }
 
-long tc_core_tick2usec(long tick)
+long tc_core_tick2time(long tick)
 {
 	return tick/tick_in_usec;
 }
@@ -58,12 +58,12 @@ long tc_core_ktime2time(long ktime)
 
 unsigned tc_calc_xmittime(unsigned rate, unsigned size)
 {
-	return tc_core_usec2tick(TIME_UNITS_PER_SEC*((double)size/rate));
+	return tc_core_time2tick(TIME_UNITS_PER_SEC*((double)size/rate));
 }
 
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
 {
-	return ((double)rate*tc_core_tick2usec(ticks))/TIME_UNITS_PER_SEC;
+	return ((double)rate*tc_core_tick2time(ticks))/TIME_UNITS_PER_SEC;
 }
 
 /*
diff --git a/tc/tc_core.h b/tc/tc_core.h
index b31813d..a139da6 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -6,9 +6,9 @@ #include <linux/pkt_sched.h>
 
 #define TIME_UNITS_PER_SEC	1000000
 
-int  tc_core_usec2big(long usec);
-long tc_core_usec2tick(long usec);
-long tc_core_tick2usec(long tick);
+int  tc_core_time2big(long time);
+long tc_core_time2tick(long time);
+long tc_core_tick2time(long tick);
 long tc_core_time2ktime(long time);
 long tc_core_ktime2time(long ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 62113fc..b73fae9 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -209,7 +209,7 @@ char * sprint_rate(__u32 rate, char *buf
 	return buf;
 }
 
-int get_usecs(unsigned *usecs, const char *str)
+int get_time(unsigned *time, const char *str)
 {
 	double t;
 	char *p;
@@ -232,26 +232,26 @@ int get_usecs(unsigned *usecs, const cha
 			return -1;
 	}
 
-	*usecs = t;
+	*time = t;
 	return 0;
 }
 
 
-void print_usecs(char *buf, int len, __u32 usec)
+void print_time(char *buf, int len, __u32 time)
 {
-	double tmp = usec;
+	double tmp = time;
 
 	if (tmp >= TIME_UNITS_PER_SEC)
 		snprintf(buf, len, "%.1fs", tmp/TIME_UNITS_PER_SEC);
 	else if (tmp >= TIME_UNITS_PER_SEC/1000)
 		snprintf(buf, len, "%.1fms", tmp/(TIME_UNITS_PER_SEC/1000));
 	else
-		snprintf(buf, len, "%uus", usec);
+		snprintf(buf, len, "%uus", time);
 }
 
-char * sprint_usecs(__u32 usecs, char *buf)
+char * sprint_time(__u32 time, char *buf)
 {
-	print_usecs(buf, SPRINT_BSIZE-1, usecs);
+	print_time(buf, SPRINT_BSIZE-1, time);
 	return buf;
 }
 
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 0778693..b713cf1 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -46,17 +46,17 @@ extern int get_rate(unsigned *rate, cons
 extern int get_percent(unsigned *percent, const char *str);
 extern int get_size(unsigned *size, const char *str);
 extern int get_size_and_cell(unsigned *size, int *cell_log, char *str);
-extern int get_usecs(unsigned *usecs, const char *str);
+extern int get_time(unsigned *time, const char *str);
 extern void print_rate(char *buf, int len, __u32 rate);
 extern void print_size(char *buf, int len, __u32 size);
 extern void print_percent(char *buf, int len, __u32 percent);
 extern void print_qdisc_handle(char *buf, int len, __u32 h);
-extern void print_usecs(char *buf, int len, __u32 usecs);
+extern void print_time(char *buf, int len, __u32 time);
 extern char * sprint_rate(__u32 rate, char *buf);
 extern char * sprint_size(__u32 size, char *buf);
 extern char * sprint_qdisc_handle(__u32 h, char *buf);
 extern char * sprint_tc_classid(__u32 h, char *buf);
-extern char * sprint_usecs(__u32 usecs, char *buf);
+extern char * sprint_time(__u32 time, char *buf);
 extern char * sprint_percent(__u32 percent, char *buf);
 
 extern void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtattr **xstats);
