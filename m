From: Christian Hesse <mail@eworm.de>
Subject: [PATCH 1/1] ip-link: in human readable output use dynamic precision length
Date: Tue,  4 Nov 2014 10:39:50 +0100
Message-ID: <1415093990-22632-1-git-send-email-mail@eworm.de>
Cc: netdev@vger.kernel.org, Christian Hesse <mail@eworm.de>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:51099 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbaKDJlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 04:41:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we use floating point numbers for human readable output we can
calculate precision length on the fly.
---
 ip/ipaddress.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index e240bb5..0ddcb0d 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -343,8 +343,8 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
 		++prefix;
 	}
 
-	snprintf(buf, sizeof(buf), "%.1f%c%s", (double) count / powi, 
-		 *prefix, use_iec ? "i" : "");
+	snprintf(buf, sizeof(buf), "%.*f%c%s", 3 - snprintf(NULL, 0, "%"PRIu64, count / powi),
+		(double) count / powi, *prefix, use_iec ? "i" : "");
 
 	fprintf(fp, "%-*s ", width, buf);
 }
-- 
2.1.3
