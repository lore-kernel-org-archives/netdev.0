From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/5] ethtool: Report an error if given an
 unrecognised option
Date: Mon, 21 Feb 2011 19:18:03 +0000
Message-ID: <1298315883.2608.70.camel@bwh-desktop>
References: <1298315809.2608.68.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:10160 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856Ab1BUTSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 14:18:05 -0500
In-Reply-To: <1298315809.2608.68.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously we would print full usage information and return 0.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index b9422d3..d28f1b2 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -807,10 +807,11 @@ static void parse_cmdline(int argc, char **argp)
 					mode = args[k].Mode;
 					break;
 				}
-			if (mode == MODE_HELP ||
-			    (!args[k].srt && argp[i][0] == '-')) {
+			if (mode == MODE_HELP) {
 				show_usage();
 				exit(0);
+			} else if (!args[k].srt && argp[i][0] == '-') {
+				exit_bad_args();
 			} else {
 				devname = argp[i];
 			}
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

