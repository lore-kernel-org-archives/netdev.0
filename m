From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/4] tc: Reformat tc_util.h
Date: Sat, 23 Jul 2016 13:28:07 +0200
Message-ID: <1469273290-18539-2-git-send-email-phil@nwl.cc>
References: <1469273290-18539-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39560 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbcGWL2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:28:42 -0400
In-Reply-To: <1469273290-18539-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Drop 'extern' keyword before function declarations.
* Add parameter names where they were missing for matters of
  consistency.
* Drop fancy indenting (e.g. tab between type and name).
* Break long lines to not exceed 80 columns.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/tc_util.h | 149 +++++++++++++++++++++++++++++++----------------------------
 1 file changed, 78 insertions(+), 71 deletions(-)

diff --git a/tc/tc_util.h b/tc/tc_util.h
index 61e60b1c55b70..744f18fdd9117 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -22,89 +22,96 @@ enum
 struct qdisc_util {
 	struct  qdisc_util *next;
 	const char *id;
-	int	(*parse_qopt)(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n);
-	int	(*print_qopt)(struct qdisc_util *qu, FILE *f, struct rtattr *opt);
-	int 	(*print_xstats)(struct qdisc_util *qu, FILE *f, struct rtattr *xstats);
-
-	int	(*parse_copt)(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n);
-	int	(*print_copt)(struct qdisc_util *qu, FILE *f, struct rtattr *opt);
+	int (*parse_qopt)(struct qdisc_util *qu, int argc,
+			  char **argv, struct nlmsghdr *n);
+	int (*print_qopt)(struct qdisc_util *qu,
+			  FILE *f, struct rtattr *opt);
+	int (*print_xstats)(struct qdisc_util *qu,
+			    FILE *f, struct rtattr *xstats);
+
+	int (*parse_copt)(struct qdisc_util *qu, int argc,
+			  char **argv, struct nlmsghdr *n);
+	int (*print_copt)(struct qdisc_util *qu, FILE *f, struct rtattr *opt);
 };
 
 extern __u16 f_proto;
 struct filter_util {
 	struct filter_util *next;
-	char	id[16];
-	int	(*parse_fopt)(struct filter_util *qu, char *fhandle, int argc,
-			      char **argv, struct nlmsghdr *n);
-	int	(*print_fopt)(struct filter_util *qu, FILE *f, struct rtattr *opt, __u32 fhandle);
+	char id[16];
+	int (*parse_fopt)(struct filter_util *qu, char *fhandle,
+			  int argc, char **argv, struct nlmsghdr *n);
+	int (*print_fopt)(struct filter_util *qu,
+			  FILE *f, struct rtattr *opt, __u32 fhandle);
 };
 
 struct action_util {
-	struct  action_util *next;
-	char    id[16];
-	int     (*parse_aopt)(struct action_util *a, int *argc, char ***argv,
-			      int code, struct nlmsghdr *n);
-	int     (*print_aopt)(struct action_util *au, FILE *f, struct rtattr *opt);
-	int     (*print_xstats)(struct action_util *au, FILE *f, struct rtattr *xstats);
+	struct action_util *next;
+	char id[16];
+	int (*parse_aopt)(struct action_util *a, int *argc,
+			  char ***argv, int code, struct nlmsghdr *n);
+	int (*print_aopt)(struct action_util *au, FILE *f, struct rtattr *opt);
+	int (*print_xstats)(struct action_util *au,
+			    FILE *f, struct rtattr *xstats);
 };
 
 struct exec_util {
-	struct	exec_util *next;
-	char	id[16];
-	int	(*parse_eopt)(struct exec_util *eu, int argc, char **argv);
+	struct exec_util *next;
+	char id[16];
+	int (*parse_eopt)(struct exec_util *eu, int argc, char **argv);
 };
 
-extern const char *get_tc_lib(void);
-
-extern struct qdisc_util *get_qdisc_kind(const char *str);
-extern struct filter_util *get_filter_kind(const char *str);
-
-extern int get_qdisc_handle(__u32 *h, const char *str);
-extern int get_rate(unsigned *rate, const char *str);
-extern int get_rate64(__u64 *rate, const char *str);
-extern int get_size(unsigned *size, const char *str);
-extern int get_size_and_cell(unsigned *size, int *cell_log, char *str);
-extern int get_time(unsigned *time, const char *str);
-extern int get_linklayer(unsigned *val, const char *arg);
-
-extern void print_rate(char *buf, int len, __u64 rate);
-extern void print_size(char *buf, int len, __u32 size);
-extern void print_qdisc_handle(char *buf, int len, __u32 h);
-extern void print_time(char *buf, int len, __u32 time);
-extern void print_linklayer(char *buf, int len, unsigned linklayer);
-
-extern char * sprint_rate(__u64 rate, char *buf);
-extern char * sprint_size(__u32 size, char *buf);
-extern char * sprint_qdisc_handle(__u32 h, char *buf);
-extern char * sprint_tc_classid(__u32 h, char *buf);
-extern char * sprint_time(__u32 time, char *buf);
-extern char * sprint_ticks(__u32 ticks, char *buf);
-extern char * sprint_linklayer(unsigned linklayer, char *buf);
-
-extern void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtattr **xstats);
-extern void print_tcstats2_attr(FILE *fp, struct rtattr *rta, char *prefix, struct rtattr **xstats);
-
-extern int get_tc_classid(__u32 *h, const char *str);
-extern int print_tc_classid(char *buf, int len, __u32 h);
-extern char * sprint_tc_classid(__u32 h, char *buf);
-
-extern int tc_print_police(FILE *f, struct rtattr *tb);
-extern int parse_police(int *, char ***, int, struct nlmsghdr *);
-
-extern char *action_n2a(int action, char *buf, int len);
-extern int  action_a2n(char *arg, int *result);
-extern int  act_parse_police(struct action_util *a,int *, char ***, int, struct nlmsghdr *);
-extern int  print_police(struct action_util *a, FILE *f,
-			 struct rtattr *tb);
-extern int  police_print_xstats(struct action_util *a,FILE *f,
-				struct rtattr *tb);
-extern int  tc_print_action(FILE *f, const struct rtattr *tb);
-extern int  tc_print_ipt(FILE *f, const struct rtattr *tb);
-extern int  parse_action(int *, char ***, int, struct nlmsghdr *);
-extern void print_tm(FILE *f, const struct tcf_t *tm);
-extern int prio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt);
-
-extern int cls_names_init(char *path);
-extern void cls_names_uninit(void);
+const char *get_tc_lib(void);
+
+struct qdisc_util *get_qdisc_kind(const char *str);
+struct filter_util *get_filter_kind(const char *str);
+
+int get_qdisc_handle(__u32 *h, const char *str);
+int get_rate(unsigned int *rate, const char *str);
+int get_rate64(__u64 *rate, const char *str);
+int get_size(unsigned int *size, const char *str);
+int get_size_and_cell(unsigned int *size, int *cell_log, char *str);
+int get_time(unsigned int *time, const char *str);
+int get_linklayer(unsigned int *val, const char *arg);
+
+void print_rate(char *buf, int len, __u64 rate);
+void print_size(char *buf, int len, __u32 size);
+void print_qdisc_handle(char *buf, int len, __u32 h);
+void print_time(char *buf, int len, __u32 time);
+void print_linklayer(char *buf, int len, unsigned int linklayer);
+
+char *sprint_rate(__u64 rate, char *buf);
+char *sprint_size(__u32 size, char *buf);
+char *sprint_qdisc_handle(__u32 h, char *buf);
+char *sprint_tc_classid(__u32 h, char *buf);
+char *sprint_time(__u32 time, char *buf);
+char *sprint_ticks(__u32 ticks, char *buf);
+char *sprint_linklayer(unsigned int linklayer, char *buf);
+
+void print_tcstats_attr(FILE *fp, struct rtattr *tb[],
+			char *prefix, struct rtattr **xstats);
+void print_tcstats2_attr(FILE *fp, struct rtattr *rta,
+			 char *prefix, struct rtattr **xstats);
+
+int get_tc_classid(__u32 *h, const char *str);
+int print_tc_classid(char *buf, int len, __u32 h);
+char *sprint_tc_classid(__u32 h, char *buf);
+
+int tc_print_police(FILE *f, struct rtattr *tb);
+int parse_police(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n);
+
+char *action_n2a(int action, char *buf, int len);
+int action_a2n(char *arg, int *result);
+int act_parse_police(struct action_util *a, int *argc_p,
+		     char ***argv_p, int tca_id, struct nlmsghdr *n);
+int print_police(struct action_util *a, FILE *f, struct rtattr *tb);
+int police_print_xstats(struct action_util *a, FILE *f, struct rtattr *tb);
+int tc_print_action(FILE *f, const struct rtattr *tb);
+int tc_print_ipt(FILE *f, const struct rtattr *tb);
+int parse_action(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n);
+void print_tm(FILE *f, const struct tcf_t *tm);
+int prio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt);
+
+int cls_names_init(char *path);
+void cls_names_uninit(void);
 
 #endif
-- 
2.8.2
