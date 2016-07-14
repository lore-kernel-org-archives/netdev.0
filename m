From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute 5/5] fou: Allowing configuring IPv6 listener
Date: Thu, 14 Jul 2016 12:22:16 -0700
Message-ID: <1468524136-3389846-6-git-send-email-tom@herbertland.com>
References: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <haoxuany@fb.com>,
	Tom Herbert <tom@herbertland.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51627 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751798AbcGNTWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 15:22:40 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6EJIxAo005906
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 246grs80nu-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:37 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 5050f56249f811e6974124be0593f280-a51fdaf0 for <netdev@vger.kernel.org>;	Thu,
 14 Jul 2016 12:22:33 -0700
In-Reply-To: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 ip/ipfou.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/ip/ipfou.c b/ip/ipfou.c
index 2a6ae17..d584a02 100644
--- a/ip/ipfou.c
+++ b/ip/ipfou.c
@@ -25,8 +25,8 @@
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip fou add port PORT { ipproto PROTO  | gue }\n");
-	fprintf(stderr, "       ip fou del port PORT\n");
+	fprintf(stderr, "Usage: ip fou add port PORT { ipproto PROTO  | gue } [ -6 ]\n");
+	fprintf(stderr, "       ip fou del port PORT [ -6 ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: PROTO { ipproto-name | 1..255 }\n");
 	fprintf(stderr, "       PORT { 1..65535 }\n");
@@ -50,6 +50,7 @@ static int fou_parse_opt(int argc, char **argv, struct nlmsghdr *n,
 	__u8 ipproto, type;
 	bool gue_set = false;
 	int ipproto_set = 0;
+	unsigned short family = AF_INET;
 
 	while (argc > 0) {
 		if (!matches(*argv, "port")) {
@@ -71,6 +72,8 @@ static int fou_parse_opt(int argc, char **argv, struct nlmsghdr *n,
 			ipproto_set = 1;
 		} else if (!matches(*argv, "gue")) {
 			gue_set = true;
+		} else if (!matches(*argv, "-6")) {
+			family = AF_INET6;
 		} else {
 			fprintf(stderr, "fou: unknown command \"%s\"?\n", *argv);
 			usage();
@@ -98,6 +101,7 @@ static int fou_parse_opt(int argc, char **argv, struct nlmsghdr *n,
 
 	addattr16(n, 1024, FOU_ATTR_PORT, port);
 	addattr8(n, 1024, FOU_ATTR_TYPE, type);
+	addattr16(n, 1024, FOU_ATTR_AF, family);
 
 	if (ipproto_set)
 		addattr8(n, 1024, FOU_ATTR_IPPROTO, ipproto);
-- 
2.8.0.rc2
