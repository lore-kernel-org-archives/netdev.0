From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] iproute2: parse flag XFRM_POLICY_ICMP
Date: Thu, 7 Apr 2011 09:37:05 +0200
Message-ID: <20110407073705.GA6523@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-101.dex002.intermedia.net ([64.78.19.88]:50364 "EHLO
	DHOST002-101.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752303Ab1DGHwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 03:52:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

parse flag XFRM_POLICY_ICMP

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 ip/ipxfrm.c      |    1 +
 ip/xfrm_policy.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index a276c0b..7a9a681 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -980,6 +980,7 @@ void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
 
 		fprintf(fp, "flag ");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_POLICY_LOCALOK, "localok");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_POLICY_ICMP, "icmp");
 		if (flags)
 			fprintf(fp, "%x", flags);
 	}
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 9ef5c09..7827f91 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -77,7 +77,7 @@ static void usage(void)
 	//fprintf(stderr, "PRIORITY - priority value(default=0)\n");
 
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
-	fprintf(stderr, "FLAG := [ localok ]\n");
+	fprintf(stderr, "FLAG := [ localok | icmp ]\n");
 
 	fprintf(stderr, "LIMIT-LIST := [ LIMIT-LIST ] | [ limit LIMIT ]\n");
 	fprintf(stderr, "LIMIT := [ [time-soft|time-hard|time-use-soft|time-use-hard] SECONDS ] |\n");
@@ -156,6 +156,8 @@ static int xfrm_policy_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 		while (1) {
 			if (strcmp(*argv, "localok") == 0)
 				*flags |= XFRM_POLICY_LOCALOK;
+			else if (strcmp(*argv, "icmp") == 0)
+				*flags |= XFRM_POLICY_ICMP;
 			else {
 				PREV_ARG(); /* back track */
 				break;
-- 
1.7.1

