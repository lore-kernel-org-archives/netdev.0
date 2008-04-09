From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [PATCH 3/7] Parsing linklayer types.
Date: Wed, 9 Apr 2008 23:02:18 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804092301230.21022@ask.diku.dk>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:60291 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265AbYDIVCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 17:02:20 -0400
In-Reply-To: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Adding a general function get_linklayer() for parsing linklayer types.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
  tc/tc_util.c |   18 ++++++++++++++++++
  tc/tc_util.h |    2 ++
  2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index cdbae42..f8472c5 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -435,6 +435,24 @@ int action_a2n(char *arg, int *result)
  	return 0;
  }

+// Function for parsing linklayer type
+int get_linklayer(unsigned int *val, char *arg)
+{
+	int res;
+	if (matches(arg, "ethernet") == 0)
+		res = LINKLAYER_ETHERNET;
+	else if (matches(arg, "atm") == 0)
+		res = LINKLAYER_ATM;
+	else if (matches(arg, "adsl") == 0)
+		res = LINKLAYER_ATM;
+	else
+		return -1; /* Indicate error */
+
+	*val = res;
+	return 0;
+}
+
+
  void print_tm(FILE * f, const struct tcf_t *tm)
  {
  	int hz = get_user_hz();
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 120d6ce..5b8253a 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -62,6 +62,8 @@ extern char * sprint_time(__u32 time, char *buf);
  extern char * sprint_ticks(__u32 ticks, char *buf);
  extern char * sprint_percent(__u32 percent, char *buf);

+extern int get_linklayer(unsigned int *val, char *arg);
+
  extern void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtattr **xstats);
  extern void print_tcstats2_attr(FILE *fp, struct rtattr *rta, char *prefix, struct rtattr **xstats);

-- 
1.5.3

