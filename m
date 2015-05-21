From: Jetchko Jekov <jetchko.jekov@nokia.com>
Subject: [PATCH] Raising the size of the buffer holding nl messages
Date: Thu, 21 May 2015 17:03:36 +0200
Message-ID: <555DF3C8.10006@nokia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040306090801080800040908"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:57130 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755921AbbEUPDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 11:03:38 -0400
Received: from demuprx017.emea.nsn-intra.net ([10.150.129.56])
	by demumfd001.nsn-inter.net (8.15.1/8.15.1) with ESMTPS id t4LF3aka031538
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 15:03:37 GMT
Received: from zeus.emea.nsn-net.net ([10.156.138.192])
	by demuprx017.emea.nsn-intra.net (8.12.11.20060308/8.12.11) with ESMTP id t4LF3aK2027178
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:03:36 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040306090801080800040908
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit





--------------040306090801080800040908
Content-Type: text/x-patch;
 name="0001-Raising-the-size-of-the-buffer-holding-nl-messages.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-Raising-the-size-of-the-buffer-holding-nl-messages.patc";
 filename*1="h"

>From 68f0dda45a4f1bca070849f3f04a409de897ee0f Mon Sep 17 00:00:00 2001
From: Jetchko Jekov <jetchko.jekov@nokia.com>
Date: Thu, 21 May 2015 16:32:24 +0200
Subject: [PATCH] Raising the size of the buffer holding nl messages.

Now it matches the size for the answer defined in rtnl_talk()
and prevents stack corruption with answer > 1024 bytes.
---
 ip/link_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/link_gre.c b/ip/link_gre.c
index 1d78387..1937261 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -53,7 +53,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	struct {
 		struct nlmsghdr n;
 		struct ifinfomsg i;
-		char buf[1024];
+		char buf[16384];
 	} req;
 	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
 	struct rtattr *tb[IFLA_MAX + 1];
-- 
2.1.0



--------------040306090801080800040908--
