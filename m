From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 04/05]: Replace "usec" by "time" in function names
Date: Fri, 23 Jun 2006 20:06:50 +0200 (MEST)
Message-ID: <20060623180650.13183.51327.sendpatchset@localhost.localdomain>
References: <20060623180642.13183.74864.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46517 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751847AbWFWSGw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 14:06:52 -0400
To: hemminger@osdl.org
In-Reply-To: <20060623180642.13183.74864.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: Replace "usec" by "time" in function names

Rename functions containing "usec" since they don't necessarily return
usec units anymore.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 67edfb2c86323a1c52a60538f677310f6c75efdf
tree 37302dfd036340aac8c7f2070ebcbc570fd634ed
parent 8e2cc14ba6fb8f940de72f307e67eb9040a5d4f7
author Patrick McHardy <kaber@trash.net> Fri, 23 Jun 2006 19:47:14 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 23 Jun 2006 19:47:14 +0200

 tc/m_estimator.c |    4 ++--
 tc/q_cbq.c       |    6 +++---
 tc/q_hfsc.c      |    6 +++---
 tc/q_netem.c     |    6 +++---
 tc/q_tbf.c       |    8 ++++----
 tc/tc_cbq.c      |    4 ++--
 tc/tc_core.c     |   10 +++++-----
 tc/tc_core.h     |    4 ++--
 tc/tc_util.c     |   14 +++++++-------
 tc/tc_util.h     |    6 +++---
 10 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/tc/m_estimator.c b/tc/m_estimator.c
index 78eda7a..898ff80 100644
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
index 045c377..648acd0 100644
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
index be0587f..6c160c9 100644
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
index 757edca..cc16a28 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -108,16 +108,16 @@ static int get_ticks(__u32 *ticks, const
 {
 	unsigned t;
 
-	if(get_usecs(&t, str))
+	if(get_time(&t, str))
 		return -1;
 	
-	*ticks = tc_core_usec2tick(t);
+	*ticks = tc_core_time2tick(t);
 	return 0;
 }
 
 static char *sprint_ticks(__u32 ticks, char *buf)
 {
-	return sprint_usecs(tc_core_tick2usec(ticks), buf);
+	return sprint_time(tc_core_tick2time(ticks), buf);
 }
 
 
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index f2ffb7e..4db4b44 100644
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
 
-	latency = tc_calc_xmittime(qopt->rate.rate, qopt->limit) - tc_core_tick2usec(qopt->buffer);
+	latency = tc_calc_xmittime(qopt->rate.rate, qopt->limit) - tc_core_tick2time(qopt->buffer);
 	if (qopt->peakrate.rate) {
-		double lat2 = tc_calc_xmittime(qopt->peakrate.rate, qopt->limit) - tc_core_tick2usec(qopt->mtu);
+		double lat2 = tc_calc_xmittime(qopt->peakrate.rate, qopt->limit) - tc_core_tick2time(qopt->mtu);
 		if (lat2 > latency)
 			latency = lat2;
 	}
-	fprintf(f, "lat %s ", sprint_usecs(tc_core_tick2usec(latency), b1));
+	fprintf(f, "lat %s ", sprint_time(tc_core_tick2time(latency), b1));
 
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
index cf49d83..063995c 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -27,12 +27,12 @@ static __u32 t2us=1;
 static __u32 us2t=1;
 static double tick_in_usec = 1;
 
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
@@ -49,12 +49,12 @@ long tc_core_ktime2time(long ktime)
 
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
index 720b6d6..52954be 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -6,8 +6,8 @@ #include <linux/pkt_sched.h>
 
 #define TIME_UNITS_PER_SEC		1000000
 
-long tc_core_usec2tick(long usec);
-long tc_core_tick2usec(long tick);
+long tc_core_time2tick(long time);
+long tc_core_tick2time(long tick);
 long tc_core_time2ktime(long time);
 long tc_core_ktime2time(long ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 2ceb631..321bac0 100644
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
index 1aa1bda..aba4adb 100644
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
