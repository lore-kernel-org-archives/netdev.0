From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 1/2] Initialize arguments to iplink_parse() by default
Date: Wed, 11 Dec 2013 14:25:10 +0200
Message-ID: <4467313.PgxQL6MHJm@tuxracer>
References: <cover.1386764590.git.popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback5.mail.ru ([94.100.176.59]:48078 "EHLO
	fallback5.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347Ab3LKMaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 07:30:16 -0500
Received: from smtp32.i.mail.ru (smtp32.i.mail.ru [94.100.177.92])
	by fallback5.mail.ru (mPOP.Fallback_MX) with ESMTP id ABE911052CC6A
	for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 16:30:07 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=48240 helo=tuxracer.localnet)
	by smtp32.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1VqivM-000608-2W
	for netdev@vger.kernel.org; Wed, 11 Dec 2013 16:29:56 +0400
In-Reply-To: <cover.1386764590.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Be consistent when dealing with arguments passed
to iplink_parse() by initializing to default values.

This fixes crash when ip-link(8) invoced with command:

  ip link add dev veth1a type veth peer

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 ip/iplink.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 58b6c20..9735c54 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -299,6 +299,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	int numtxqueues = -1;
 	int numrxqueues = -1;
 
+	*name = *type = *link = *dev = NULL;
 	*group = -1;
 	ret = argc;
 
@@ -498,15 +499,11 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 
 static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 {
-	int len;
-	char *dev = NULL;
-	char *name = NULL;
-	char *link = NULL;
-	char *type = NULL;
+	char *name, *type, *link, *dev;
 	int group;
 	struct link_util *lu = NULL;
 	struct iplink_req req;
-	int ret;
+	int len, ret;
 
 	memset(&req, 0, sizeof(req));
 
-- 
1.7.10.4
