From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 3/5] ethtool: Allow for long options with no short
 option and without a device name
Date: Mon, 21 Feb 2011 19:18:36 +0000
Message-ID: <1298315916.2608.71.camel@bwh-desktop>
References: <1298315809.2608.68.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10227 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039Ab1BUTSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 14:18:39 -0500
In-Reply-To: <1298315809.2608.68.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change loop conditions to check for a long option string.

Generalise check for whether option requires a device name.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index d28f1b2..8246bda 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -287,12 +287,16 @@ static void show_usage(void)
 	fprintf(stdout,
 		"Usage:\n"
 		"ethtool DEVNAME\tDisplay standard information about device\n");
-	for (i = 0; args[i].srt; i++) {
-		fprintf(stdout, "        ethtool %s|%s %s\t%s\n%s",
-			args[i].srt, args[i].lng,
-			strstr(args[i].srt, "-h") ? "\t" : "DEVNAME",
-			args[i].help,
-			args[i].opthelp ? args[i].opthelp : "");
+	for (i = 0; args[i].lng; i++) {
+		fputs("        ethtool ", stdout);
+		if (args[i].srt)
+			fprintf(stdout, "%s|", args[i].srt);
+		fprintf(stdout, "%s %s\t%s\n",
+			args[i].lng,
+			args[i].Mode < 0 ? "\t" : "DEVNAME",
+			args[i].help);
+		if (args[i].opthelp)
+			fputs(args[i].opthelp, stdout);
 	}
 }
 
@@ -801,8 +805,9 @@ static void parse_cmdline(int argc, char **argp)
 	for (i = 1; i < argc; i++) {
 		switch (i) {
 		case 1:
-			for (k = 0; args[k].srt; k++)
-				if (!strcmp(argp[i], args[k].srt) ||
+			for (k = 0; args[k].lng; k++)
+				if ((args[k].srt &&
+				     !strcmp(argp[i], args[k].srt)) ||
 				    !strcmp(argp[i], args[k].lng)) {
 					mode = args[k].Mode;
 					break;
@@ -810,7 +815,7 @@ static void parse_cmdline(int argc, char **argp)
 			if (mode == MODE_HELP) {
 				show_usage();
 				exit(0);
-			} else if (!args[k].srt && argp[i][0] == '-') {
+			} else if (!args[k].lng && argp[i][0] == '-') {
 				exit_bad_args();
 			} else {
 				devname = argp[i];
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

