From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute v2 5/5] fou: Allowing configuring IPv6 listener
Date: Thu, 4 Aug 2016 13:34:57 -0700
Message-ID: <1470342897-2004557-6-git-send-email-tom@herbertland.com>
References: <1470342897-2004557-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Tom Herbert <tom@herbertland.com>
To: <shemming@brocade.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:32977 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965872AbcHDUfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 16:35:18 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u74KRPFl009124
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2016 13:35:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24marrgwkr-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 13:35:17 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 f4135e485a8211e6b5790002c99293a0-263fcaf0 for <netdev@vger.kernel.org>;	Thu,
 04 Aug 2016 13:35:16 -0700
In-Reply-To: <1470342897-2004557-1-git-send-email-tom@herbertland.com>
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
