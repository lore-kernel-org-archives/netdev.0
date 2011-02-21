From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 5/5] ethtool: Add --version option
Date: Mon, 21 Feb 2011 19:19:19 +0000
Message-ID: <1298315959.2608.73.camel@bwh-desktop>
References: <1298315809.2608.68.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:10328 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191Ab1BUTTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 14:19:21 -0500
In-Reply-To: <1298315809.2608.68.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in |    5 +++++
 ethtool.c    |    6 ++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 133825b..8b04335 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -100,6 +100,8 @@ ethtool \- query or control network driver and hardware settings
 
 .B ethtool \-h|\-\-help
 
+.B ethtool \-\-version
+
 .B ethtool \-a|\-\-show\-pause
 .I ethX
 
@@ -310,6 +312,9 @@ settings of the specified device.
 .B \-h \-\-help
 Shows a short help message.
 .TP
+.B \-\-version
+Shows the ethtool version number.
+.TP
 .B \-a \-\-show\-pause
 Queries the specified Ethernet device for pause parameter information.
 .TP
diff --git a/ethtool.c b/ethtool.c
index 32a97f6..e9cb2c9 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -115,6 +115,7 @@ static int do_permaddr(int fd, struct ifreq *ifr);
 static int send_ioctl(int fd, struct ifreq *ifr);
 
 static enum {
+	MODE_VERSION = -2,
 	MODE_HELP = -1,
 	MODE_GSET=0,
 	MODE_SSET,
@@ -264,6 +265,7 @@ static struct option {
     { "-P", "--show-permaddr", MODE_PERMADDR,
 		"Show permanent hardware address" },
     { "-h", "--help", MODE_HELP, "Show this help" },
+    { NULL, "--version", MODE_VERSION, "Show version number" },
     {}
 };
 
@@ -816,6 +818,10 @@ static void parse_cmdline(int argc, char **argp)
 			if (mode == MODE_HELP) {
 				show_usage();
 				exit(0);
+			} else if (mode == MODE_VERSION) {
+				fprintf(stdout,
+					PACKAGE " version " VERSION "\n");
+				exit(0);
 			} else if (!args[k].lng && argp[i][0] == '-') {
 				exit_bad_args();
 			} else {
-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

