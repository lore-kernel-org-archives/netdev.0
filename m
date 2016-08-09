From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute v3 5/5] fou: Allowing configuring IPv6 listener
Date: Tue, 9 Aug 2016 14:41:39 -0700
Message-ID: <1470778899-2854697-6-git-send-email-tom@herbertland.com>
References: <1470778899-2854697-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Tom Herbert <tom@herbertland.com>
To: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:20527 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932518AbcHIVmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 17:42:06 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u79LXcOA024633
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2016 14:42:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 24nbjc36x6-4
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 14:42:05 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 146ecd6c5e7a11e68e0d24be05956610-2c3fdaf0 for <netdev@vger.kernel.org>;	Tue,
 09 Aug 2016 14:41:50 -0700
In-Reply-To: <1470778899-2854697-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 ip/ipfou.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ip/ipfou.c b/ip/ipfou.c
index 2a6ae17..0673d11 100644
--- a/ip/ipfou.c
+++ b/ip/ipfou.c
@@ -25,8 +25,9 @@
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip fou add port PORT { ipproto PROTO  | gue }\n");
-	fprintf(stderr, "       ip fou del port PORT\n");
+	fprintf(stderr, "Usage: ip fou add port PORT "
+		"{ ipproto PROTO  | gue } [ -6 ]\n");
+	fprintf(stderr, "       ip fou del port PORT [ -6 ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: PROTO { ipproto-name | 1..255 }\n");
 	fprintf(stderr, "       PORT { 1..65535 }\n");
@@ -50,6 +51,7 @@ static int fou_parse_opt(int argc, char **argv, struct nlmsghdr *n,
 	__u8 ipproto, type;
 	bool gue_set = false;
 	int ipproto_set = 0;
+	unsigned short family = AF_INET;
 
 	while (argc > 0) {
 		if (!matches(*argv, "port")) {
@@ -71,6 +73,8 @@ static int fou_parse_opt(int argc, char **argv, struct nlmsghdr *n,
 			ipproto_set = 1;
 		} else if (!matches(*argv, "gue")) {
 			gue_set = true;
+		} else if (!matches(*argv, "-6")) {
+			family = AF_INET6;
 		} else {
 			fprintf(stderr, "fou: unknown command \"%s\"?\n", *argv);
 			usage();
@@ -98,6 +102,7 @@ static int fou_parse_opt(int argc, char **argv, struct nlmsghdr *n,
 
 	addattr16(n, 1024, FOU_ATTR_PORT, port);
 	addattr8(n, 1024, FOU_ATTR_TYPE, type);
+	addattr16(n, 1024, FOU_ATTR_AF, family);
 
 	if (ipproto_set)
 		addattr8(n, 1024, FOU_ATTR_IPPROTO, ipproto);
-- 
2.8.0.rc2
