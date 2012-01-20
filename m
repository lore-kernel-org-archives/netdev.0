From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] red: fix adaptive spelling
Date: Fri, 20 Jan 2012 16:10:13 +0100
Message-ID: <1327072213.12389.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1323385900.2529.12.camel@edumazet-laptop>
	 <20111208164426.03248ca8@nehalam.linuxnetplumber.net>
	 <1323403837.2529.14.camel@edumazet-laptop>
	 <20111209093309.04b32e27@nehalam.linuxnetplumber.net>
	 <1323455459.4016.7.camel@edumazet-laptop>
	 <20120119144711.359077d6@nehalam.linuxnetplumber.net>
	 <20120119173318.00000c73@unknown>
	 <20120119192126.1f0d8b15@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:63781 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab2ATPKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 10:10:17 -0500
Received: by wics10 with SMTP id s10so495062wic.19
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2012 07:10:15 -0800 (PST)
In-Reply-To: <20120119192126.1f0d8b15@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 tc/q_red.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/tc/q_red.c b/tc/q_red.c
index 0e5d228..a4b5175 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -28,7 +28,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... red limit BYTES [min BYTES] [max BYTES] avpkt BYTES [burst PACKETS]\n");
-	fprintf(stderr, "               [adaptative] [probability PROBABILITY] bandwidth KBPS\n");
+	fprintf(stderr, "               [adaptive] [probability PROBABILITY] bandwidth KBPS\n");
 	fprintf(stderr, "               [ecn] [harddrop]\n");
 }
 
@@ -95,6 +95,8 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 			opt.flags |= TC_RED_HARDDROP;
 		} else if (strcmp(*argv, "adaptative") == 0) {
 			opt.flags |= TC_RED_ADAPTATIVE;
+		} else if (strcmp(*argv, "adaptive") == 0) {
+			opt.flags |= TC_RED_ADAPTATIVE;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -184,7 +186,7 @@ static int red_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (qopt->flags & TC_RED_HARDDROP)
 		fprintf(f, "harddrop ");
 	if (qopt->flags & TC_RED_ADAPTATIVE)
-		fprintf(f, "adaptative ");
+		fprintf(f, "adaptive ");
 	if (show_details) {
 		fprintf(f, "ewma %u ", qopt->Wlog);
 		if (max_P)
