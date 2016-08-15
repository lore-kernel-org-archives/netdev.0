From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute] ipila: Fixed unitialized variables
Date: Mon, 15 Aug 2016 16:30:22 -0700
Message-ID: <1471303822-1486672-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Tom Herbert <tom@herbertland.com>
To: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56892 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752316AbcHOXa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 19:30:28 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7FNTiZJ018928
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 16:30:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24unjvrheh-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 16:30:28 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 3f306662634011e6b96a0002c9dfb610-d07f1aa0 for <netdev@vger.kernel.org>;	Mon,
 15 Aug 2016 16:30:27 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize locator and locator_match to zero and only do
addattr if they have been set.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 ip/ipila.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/ip/ipila.c b/ip/ipila.c
index c30bdbf..57f8c79 100644
--- a/ip/ipila.c
+++ b/ip/ipila.c
@@ -149,8 +149,8 @@ static int do_list(int argc, char **argv)
 static int ila_parse_opt(int argc, char **argv, struct nlmsghdr *n,
 			 bool adding)
 {
-	__u64 locator;
-	__u64 locator_match;
+	__u64 locator = 0;
+	__u64 locator_match = 0;
 	int ifindex = 0;
 	bool loc_set = false;
 	bool loc_match_set = false;
@@ -202,8 +202,11 @@ static int ila_parse_opt(int argc, char **argv, struct nlmsghdr *n,
 		}
 	}
 
-	addattr64(n, 1024, ILA_ATTR_LOCATOR_MATCH, locator_match);
-	addattr64(n, 1024, ILA_ATTR_LOCATOR, locator);
+	if (loc_match_set)
+		addattr64(n, 1024, ILA_ATTR_LOCATOR_MATCH, locator_match);
+
+	if (loc_set)
+		addattr64(n, 1024, ILA_ATTR_LOCATOR, locator);
 
 	if (ifindex_set)
 		addattr32(n, 1024, ILA_ATTR_IFINDEX, ifindex);
-- 
2.8.0.rc2
