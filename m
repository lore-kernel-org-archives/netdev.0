From: Andreas Schwab <schwab@linux-m68k.org>
Subject: [PATCH] iproute2: remove useless use of buffer
Date: Sat, 06 Nov 2010 10:26:29 +0100
Message-ID: <m262wals56.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:58845 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab0KFJ0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Nov 2010 05:26:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print directly to the file instead of going through a buffer.

Signed-off-by: Andreas Schwab <schwab@linux-m68k.org>
---
 ip/ipaddress.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 19b3d6e..fc306e6 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -613,23 +613,21 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		fprintf(fp, "%s", (char*)RTA_DATA(rta_tb[IFA_LABEL]));
 	if (rta_tb[IFA_CACHEINFO]) {
 		struct ifa_cacheinfo *ci = RTA_DATA(rta_tb[IFA_CACHEINFO]);
-		char buf[128];
 		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "       valid_lft ");
 		if (ci->ifa_valid == INFINITY_LIFE_TIME)
-			sprintf(buf, "valid_lft forever");
+			fprintf(fp, "forever");
 		else
-			sprintf(buf, "valid_lft %usec", ci->ifa_valid);
+			fprintf(fp, "%usec", ci->ifa_valid);
+		fprintf(fp, " preferred_lft ");
 		if (ci->ifa_prefered == INFINITY_LIFE_TIME)
-			sprintf(buf+strlen(buf), " preferred_lft forever");
+			fprintf(fp, "forever");
 		else {
 			if (deprecated)
-				sprintf(buf+strlen(buf), " preferred_lft %dsec",
-					ci->ifa_prefered);
+				fprintf(fp, "%dsec", ci->ifa_prefered);
 			else
-				sprintf(buf+strlen(buf), " preferred_lft %usec",
-					ci->ifa_prefered);
+				fprintf(fp, "%usec", ci->ifa_prefered);
 		}
-		fprintf(fp, "       %s", buf);
 	}
 	fprintf(fp, "\n");
 	fflush(fp);
-- 
1.7.3.2


-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
