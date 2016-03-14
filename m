From: kan.liang@intel.com
Subject: [PATCH 1/5] ethtool: move option parsing related codes into function
Date: Mon, 14 Mar 2016 02:30:03 -0700
Message-ID: <1457947807-4804-1-git-send-email-kan.liang@intel.com>
Cc: davem@davemloft.net, nicolas.dichtel@6wind.com,
	ben@decadent.org.uk, jesse.brandeburg@intel.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Kan Liang <kan.liang@intel.com>
To: bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30789 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbcCNQ7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 12:59:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Move option parsing code into find_option function.
No behavior changes.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 ethtool.c | 49 +++++++++++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 18 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 0cd0d4f..bd0583c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4223,6 +4223,29 @@ static int show_usage(struct cmd_context *ctx)
 	return 0;
 }
 
+static int find_option(int argc, char **argp)
+{
+	const char *opt;
+	size_t len;
+	int k;
+
+	for (k = 0; args[k].opts; k++) {
+		opt = args[k].opts;
+		for (;;) {
+			len = strcspn(opt, "|");
+			if (strncmp(*argp, opt, len) == 0 &&
+			    (*argp)[len] == 0)
+				return k;
+
+			if (opt[len] == 0)
+				break;
+			opt += len + 1;
+		}
+	}
+
+	return -1;
+}
+
 int main(int argc, char **argp)
 {
 	int (*func)(struct cmd_context *);
@@ -4240,24 +4263,14 @@ int main(int argc, char **argp)
 	 */
 	if (argc == 0)
 		exit_bad_args();
-	for (k = 0; args[k].opts; k++) {
-		const char *opt;
-		size_t len;
-		opt = args[k].opts;
-		for (;;) {
-			len = strcspn(opt, "|");
-			if (strncmp(*argp, opt, len) == 0 &&
-			    (*argp)[len] == 0) {
-				argp++;
-				argc--;
-				func = args[k].func;
-				want_device = args[k].want_device;
-				goto opt_found;
-			}
-			if (opt[len] == 0)
-				break;
-			opt += len + 1;
-		}
+
+	k = find_option(argc, argp);
+	if (k > 0) {
+		argp++;
+		argc--;
+		func = args[k].func;
+		want_device = args[k].want_device;
+		goto opt_found;
 	}
 	if ((*argp)[0] == '-')
 		exit_bad_args();
-- 
2.5.0
