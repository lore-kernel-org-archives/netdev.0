From: Christian Hesse <mail@eworm.de>
Subject: [PATCH v2 1/1] ip-link: in human readable output use dynamic precision length
Date: Tue,  4 Nov 2014 11:50:08 +0100
Message-ID: <1415098208-17942-1-git-send-email-mail@eworm.de>
References: <20141104114421.6a7f9de5@leda.localdomain>
Cc: netdev@vger.kernel.org, Christian Hesse <mail@eworm.de>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:59168 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbaKDKvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 05:51:09 -0500
In-Reply-To: <20141104114421.6a7f9de5@leda.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 ip/ipaddress.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index e240bb5..55cbc77 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -324,6 +324,7 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
 	const char *prefix = "kMGTPE";
 	const unsigned int base = use_iec ? 1024 : 1000;
 	uint64_t powi = 1;
+	int precision;
 	char buf[64];
 
 	if (!human_readable || count < base) {
@@ -343,8 +344,11 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
 		++prefix;
 	}
 
-	snprintf(buf, sizeof(buf), "%.1f%c%s", (double) count / powi, 
-		 *prefix, use_iec ? "i" : "");
+	if ((precision = 3 - snprintf(NULL, 0, "%"PRIu64, count / powi)) < 0)
+		precision = 0;
+
+	snprintf(buf, sizeof(buf), "%.*f%c%s", precision,
+		(double) count / powi, *prefix, use_iec ? "i" : "");
 
 	fprintf(fp, "%-*s ", width, buf);
 }
-- 
2.1.3
