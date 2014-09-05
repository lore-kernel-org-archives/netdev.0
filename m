From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch iproute2] iplink: forbid negative ifindex and modifying ifindex
Date: Fri,  5 Sep 2014 16:36:14 -0700
Message-ID: <1409960174-11208-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:58910 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbaIEXgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 19:36:19 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so4116987pdj.24
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 16:36:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 ip/iplink.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index ea06871..a8a19dd 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -400,6 +400,8 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		} else if (strcmp(*argv, "index") == 0) {
 			NEXT_ARG();
 			*index = atoi(*argv);
+			if (*index < 0)
+				invarg("Invalid \"index\" value", *argv);
 		} else if (matches(*argv, "link") == 0) {
 			NEXT_ARG();
 			*link = *argv;
@@ -607,7 +609,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	char *name = NULL;
 	char *link = NULL;
 	char *type = NULL;
-	int index = 0;
+	int index = -1;
 	int group;
 	struct link_util *lu = NULL;
 	struct iplink_req req;
@@ -658,6 +660,11 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 					"argument is required.\n");
 			exit(-1);
 		}
+		if (cmd == RTM_NEWLINK && index != -1) {
+			fprintf(stderr, "index can be used only when "
+					"creating devices.\n");
+			exit(-1);
+		}
 
 		req.i.ifi_index = ll_name_to_index(dev);
 		if (req.i.ifi_index == 0) {
-- 
1.8.3.1
