From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH v2 1/2] libxt_hashlimit: Prepare libxt_hashlimit.c for
 revision 2
Date: Thu, 7 Jul 2016 19:34:19 -0400
Message-ID: <20160707233419.GC5026@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johunt@akamai.com, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	pai.vishwain@gmail.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:25684 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753044AbcGGXeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 19:34:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am planning to add a revision 2 for the hashlimit xtables module to
support higher packets per second rates. This patch renames all the
functions and variables related to revision 1 by adding _v1 at the end of
the names.

Signed-off-by: Vishwanath Pai <vpai@akamai.com>
Signed-off-by: Joshua Hunt <johunt@akamai.com>
---
 extensions/libxt_hashlimit.c           | 80 +++++++++++++++++-----------------
 include/linux/netfilter/xt_hashlimit.h |  2 +-
 2 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/extensions/libxt_hashlimit.c b/extensions/libxt_hashlimit.c
index c5b8d77..ad7fb93 100644
--- a/extensions/libxt_hashlimit.c
+++ b/extensions/libxt_hashlimit.c
@@ -23,7 +23,7 @@
 #include <linux/netfilter/xt_hashlimit.h>
 
 #define XT_HASHLIMIT_BURST	5
-#define XT_HASHLIMIT_BURST_MAX	10000
+#define XT_HASHLIMIT_BURST_MAX_v1	10000
 
 #define XT_HASHLIMIT_BYTE_EXPIRE	15
 #define XT_HASHLIMIT_BYTE_EXPIRE_BURST	60
@@ -98,7 +98,7 @@ static const struct xt_option_entry hashlimit_opts[] = {
 	{.name = "hashlimit", .id = O_UPTO, .excl = F_ABOVE,
 	 .type = XTTYPE_STRING},
 	{.name = "hashlimit-burst", .id = O_BURST, .type = XTTYPE_UINT32,
-	 .min = 1, .max = XT_HASHLIMIT_BURST_MAX, .flags = XTOPT_PUT,
+	 .min = 1, .max = XT_HASHLIMIT_BURST_MAX_v1, .flags = XTOPT_PUT,
 	 XTOPT_POINTER(s, cfg.burst)},
 	{.name = "hashlimit-htable-size", .id = O_HTABLE_SIZE,
 	 .type = XTTYPE_UINT32, .flags = XTOPT_PUT,
@@ -121,7 +121,7 @@ static const struct xt_option_entry hashlimit_opts[] = {
 #undef s
 
 #define s struct xt_hashlimit_mtinfo1
-static const struct xt_option_entry hashlimit_mt_opts[] = {
+static const struct xt_option_entry hashlimit_mt_opts_v1[] = {
 	{.name = "hashlimit-upto", .id = O_UPTO, .excl = F_ABOVE,
 	 .type = XTTYPE_STRING, .flags = XTOPT_INVERT},
 	{.name = "hashlimit-above", .id = O_ABOVE, .excl = F_UPTO,
@@ -174,10 +174,10 @@ static uint32_t get_factor(int chr)
 	return 1;
 }
 
-static void burst_error(void)
+static void burst_error_v1(void)
 {
 	xtables_error(PARAMETER_PROBLEM, "bad value for option "
-			"\"--hashlimit-burst\", or out of range (1-%u).", XT_HASHLIMIT_BURST_MAX);
+			"\"--hashlimit-burst\", or out of range (1-%u).", XT_HASHLIMIT_BURST_MAX_v1);
 }
 
 static uint32_t parse_burst(const char *burst, struct xt_hashlimit_mtinfo1 *info)
@@ -186,8 +186,8 @@ static uint32_t parse_burst(const char *burst, struct xt_hashlimit_mtinfo1 *info
 	char *end;
 
 	if (!xtables_strtoul(burst, &end, &v, 1, UINT32_MAX) ||
-	    (*end == 0 && v > XT_HASHLIMIT_BURST_MAX))
-		burst_error();
+	    (*end == 0 && v > XT_HASHLIMIT_BURST_MAX_v1))
+		burst_error_v1();
 
 	v *= get_factor(*end);
 	if (v > UINT32_MAX)
@@ -253,7 +253,7 @@ int parse_rate(const char *rate, uint32_t *val, struct hashlimit_mt_udata *ud)
 	if (!r)
 		return 0;
 
-	*val = XT_HASHLIMIT_SCALE * ud->mult / r;
+	*val = XT_HASHLIMIT_SCALE_v1 * ud->mult / r;
 	if (*val == 0)
 		/*
 		 * The rate maps to infinity. (1/day is the minimum they can
@@ -272,7 +272,7 @@ static void hashlimit_init(struct xt_entry_match *m)
 
 }
 
-static void hashlimit_mt4_init(struct xt_entry_match *match)
+static void hashlimit_mt4_init_v1(struct xt_entry_match *match)
 {
 	struct xt_hashlimit_mtinfo1 *info = (void *)match->data;
 
@@ -283,7 +283,7 @@ static void hashlimit_mt4_init(struct xt_entry_match *match)
 	info->cfg.dstmask     = 32;
 }
 
-static void hashlimit_mt6_init(struct xt_entry_match *match)
+static void hashlimit_mt6_init_v1(struct xt_entry_match *match)
 {
 	struct xt_hashlimit_mtinfo1 *info = (void *)match->data;
 
@@ -342,7 +342,7 @@ static void hashlimit_parse(struct xt_option_call *cb)
 	}
 }
 
-static void hashlimit_mt_parse(struct xt_option_call *cb)
+static void hashlimit_mt_parse_v1(struct xt_option_call *cb)
 {
 	struct xt_hashlimit_mtinfo1 *info = cb->data;
 
@@ -395,7 +395,7 @@ static void hashlimit_check(struct xt_fcheck_call *cb)
 		info->cfg.expire = udata->mult * 1000; /* from s to msec */
 }
 
-static void hashlimit_mt_check(struct xt_fcheck_call *cb)
+static void hashlimit_mt_check_v1(struct xt_fcheck_call *cb)
 {
 	const struct hashlimit_mt_udata *udata = cb->udata;
 	struct xt_hashlimit_mtinfo1 *info = cb->data;
@@ -421,18 +421,18 @@ static void hashlimit_mt_check(struct xt_fcheck_call *cb)
 				info->cfg.expire = XT_HASHLIMIT_BYTE_EXPIRE_BURST * 1000;
 		}
 		info->cfg.burst = burst;
-	} else if (info->cfg.burst > XT_HASHLIMIT_BURST_MAX)
-		burst_error();
+	} else if (info->cfg.burst > XT_HASHLIMIT_BURST_MAX_v1)
+		burst_error_v1();
 }
 
-static const struct rates
+static const struct rates_v1
 {
 	const char *name;
 	uint32_t mult;
-} rates[] = { { "day", XT_HASHLIMIT_SCALE*24*60*60 },
-	      { "hour", XT_HASHLIMIT_SCALE*60*60 },
-	      { "min", XT_HASHLIMIT_SCALE*60 },
-	      { "sec", XT_HASHLIMIT_SCALE } };
+} rates_v1[] = { { "day", XT_HASHLIMIT_SCALE_v1*24*60*60 },
+		 { "hour", XT_HASHLIMIT_SCALE_v1*60*60 },
+		 { "min", XT_HASHLIMIT_SCALE_v1*60 },
+		 { "sec", XT_HASHLIMIT_SCALE_v1 } };
 
 static uint32_t print_rate(uint32_t period)
 {
@@ -443,14 +443,14 @@ static uint32_t print_rate(uint32_t period)
 		return 0;
 	}
 
-	for (i = 1; i < ARRAY_SIZE(rates); ++i)
-		if (period > rates[i].mult
-            || rates[i].mult/period < rates[i].mult%period)
+	for (i = 1; i < ARRAY_SIZE(rates_v1); ++i)
+		if (period > rates_v1[i].mult
+            || rates_v1[i].mult/period < rates_v1[i].mult%period)
 			break;
 
-	printf(" %u/%s", rates[i-1].mult / period, rates[i-1].name);
+	printf(" %u/%s", rates_v1[i-1].mult / period, rates_v1[i-1].name);
 	/* return in msec */
-	return rates[i-1].mult / XT_HASHLIMIT_SCALE * 1000;
+	return rates_v1[i-1].mult / XT_HASHLIMIT_SCALE_v1 * 1000;
 }
 
 static const struct {
@@ -574,7 +574,7 @@ hashlimit_mt_print(const struct xt_hashlimit_mtinfo1 *info, unsigned int dmask)
 }
 
 static void
-hashlimit_mt4_print(const void *ip, const struct xt_entry_match *match,
+hashlimit_mt4_print_v1(const void *ip, const struct xt_entry_match *match,
                    int numeric)
 {
 	const struct xt_hashlimit_mtinfo1 *info = (const void *)match->data;
@@ -583,7 +583,7 @@ hashlimit_mt4_print(const void *ip, const struct xt_entry_match *match,
 }
 
 static void
-hashlimit_mt6_print(const void *ip, const struct xt_entry_match *match,
+hashlimit_mt6_print_v1(const void *ip, const struct xt_entry_match *match,
                    int numeric)
 {
 	const struct xt_hashlimit_mtinfo1 *info = (const void *)match->data;
@@ -656,7 +656,7 @@ hashlimit_mt_save(const struct xt_hashlimit_mtinfo1 *info, unsigned int dmask)
 }
 
 static void
-hashlimit_mt4_save(const void *ip, const struct xt_entry_match *match)
+hashlimit_mt4_save_v1(const void *ip, const struct xt_entry_match *match)
 {
 	const struct xt_hashlimit_mtinfo1 *info = (const void *)match->data;
 
@@ -664,7 +664,7 @@ hashlimit_mt4_save(const void *ip, const struct xt_entry_match *match)
 }
 
 static void
-hashlimit_mt6_save(const void *ip, const struct xt_entry_match *match)
+hashlimit_mt6_save_v1(const void *ip, const struct xt_entry_match *match)
 {
 	const struct xt_hashlimit_mtinfo1 *info = (const void *)match->data;
 
@@ -696,12 +696,12 @@ static struct xtables_match hashlimit_mt_reg[] = {
 		.size          = XT_ALIGN(sizeof(struct xt_hashlimit_mtinfo1)),
 		.userspacesize = offsetof(struct xt_hashlimit_mtinfo1, hinfo),
 		.help          = hashlimit_mt_help,
-		.init          = hashlimit_mt4_init,
-		.x6_parse      = hashlimit_mt_parse,
-		.x6_fcheck     = hashlimit_mt_check,
-		.print         = hashlimit_mt4_print,
-		.save          = hashlimit_mt4_save,
-		.x6_options    = hashlimit_mt_opts,
+		.init          = hashlimit_mt4_init_v1,
+		.x6_parse      = hashlimit_mt_parse_v1,
+		.x6_fcheck     = hashlimit_mt_check_v1,
+		.print         = hashlimit_mt4_print_v1,
+		.save          = hashlimit_mt4_save_v1,
+		.x6_options    = hashlimit_mt_opts_v1,
 		.udata_size    = sizeof(struct hashlimit_mt_udata),
 	},
 	{
@@ -712,12 +712,12 @@ static struct xtables_match hashlimit_mt_reg[] = {
 		.size          = XT_ALIGN(sizeof(struct xt_hashlimit_mtinfo1)),
 		.userspacesize = offsetof(struct xt_hashlimit_mtinfo1, hinfo),
 		.help          = hashlimit_mt_help,
-		.init          = hashlimit_mt6_init,
-		.x6_parse      = hashlimit_mt_parse,
-		.x6_fcheck     = hashlimit_mt_check,
-		.print         = hashlimit_mt6_print,
-		.save          = hashlimit_mt6_save,
-		.x6_options    = hashlimit_mt_opts,
+		.init          = hashlimit_mt6_init_v1,
+		.x6_parse      = hashlimit_mt_parse_v1,
+		.x6_fcheck     = hashlimit_mt_check_v1,
+		.print         = hashlimit_mt6_print_v1,
+		.save          = hashlimit_mt6_save_v1,
+		.x6_options    = hashlimit_mt_opts_v1,
 		.udata_size    = sizeof(struct hashlimit_mt_udata),
 	},
 };
diff --git a/include/linux/netfilter/xt_hashlimit.h b/include/linux/netfilter/xt_hashlimit.h
index 141efbd..0af5477 100644
--- a/include/linux/netfilter/xt_hashlimit.h
+++ b/include/linux/netfilter/xt_hashlimit.h
@@ -4,7 +4,7 @@
 #include <linux/types.h>
 
 /* timings are in milliseconds. */
-#define XT_HASHLIMIT_SCALE 10000
+#define XT_HASHLIMIT_SCALE_v1 10000
 /* 1/10,000 sec period => max of 10,000/sec.  Min rate is then 429490
    seconds, or one packet every 59 hours. */
 
-- 
1.9.1
