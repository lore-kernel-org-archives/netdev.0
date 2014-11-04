From: Christian Hesse <mail@eworm.de>
Subject: [PATCH v3 1/1] ip-link: in human readable output use dynamic precision length
Date: Tue,  4 Nov 2014 22:17:15 +0100
Message-ID: <1415135835-17297-1-git-send-email-mail@eworm.de>
References: <20141104221038.440fd9d7@leda.localdomain>
Cc: netdev@vger.kernel.org, Christian Hesse <mail@eworm.de>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:44853 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbaKDVRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 16:17:32 -0500
In-Reply-To: <20141104221038.440fd9d7@leda.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 ip/ipaddress.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index e240bb5..db39437 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -324,6 +324,8 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
 	const char *prefix = "kMGTPE";
 	const unsigned int base = use_iec ? 1024 : 1000;
 	uint64_t powi = 1;
+	uint16_t powj = 1;
+	uint8_t precision = 2;
 	char buf[64];
 
 	if (!human_readable || count < base) {
@@ -343,8 +345,15 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
 		++prefix;
 	}
 
-	snprintf(buf, sizeof(buf), "%.1f%c%s", (double) count / powi, 
-		 *prefix, use_iec ? "i" : "");
+	/* try to guess a good number of digits for precision */
+	for (; precision > 0; precision--) {
+		powj *= 10;
+		if (count / powi < powj)
+			break;
+	}
+
+	snprintf(buf, sizeof(buf), "%.*f%c%s", precision,
+		(double) count / powi, *prefix, use_iec ? "i" : "");
 
 	fprintf(fp, "%-*s ", width, buf);
 }
-- 
2.1.3
