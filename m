From: kan.liang@intel.com
Subject: [PATCH 1/5] ethtool: move option parsing related codes into function
Date: Sun, 15 May 2016 00:14:32 -0700
Message-ID: <1463296476-32493-1-git-send-email-kan.liang@intel.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nicolas.dichtel@6wind.com, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59591 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262AbcEOOkj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 10:40:39 -0400
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
