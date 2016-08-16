From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 3/4] fou: show usage even if the module is not available
Date: Tue, 16 Aug 2016 16:26:57 +0200
Message-ID: <96f296e33f93c9915e9abb65459a0c211dfd79e4.1471356460.git.sd@queasysnail.net>
References: <cover.1471356460.git.sd@queasysnail.net>
Cc: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51014 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbcHPO1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 10:27:18 -0400
In-Reply-To: <cover.1471356460.git.sd@queasysnail.net>
In-Reply-To: <cover.1471356460.git.sd@queasysnail.net>
References: <cover.1471356460.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the `ip fou` command tries to initialize a genl context even
when we just want to see the help for the command, which doesn't require
to talk to the kernel at all.

Delay genl initialization, which can fail if the module isn't loaded,
until the point where we will actually need it.

Fixes: 6928747b6e79 ("ip fou: Support to configure foo-over-udp RX")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 ip/ipfou.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/ip/ipfou.c b/ip/ipfou.c
index 9f0911215749..00dbe150710d 100644
--- a/ip/ipfou.c
+++ b/ip/ipfou.c
@@ -136,19 +136,19 @@ static int do_del(int argc, char **argv)
 
 int do_ipfou(int argc, char **argv)
 {
-	if (genl_init_handle(&genl_rth, FOU_GENL_NAME, &genl_family))
-		exit(1);
-
 	if (argc < 1)
 		usage();
 
+	if (matches(*argv, "help") == 0)
+		usage();
+
+	if (genl_init_handle(&genl_rth, FOU_GENL_NAME, &genl_family))
+		exit(1);
+
 	if (matches(*argv, "add") == 0)
 		return do_add(argc-1, argv+1);
 	if (matches(*argv, "delete") == 0)
 		return do_del(argc-1, argv+1);
-	if (matches(*argv, "help") == 0)
-		usage();
-
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip fou help\".\n", *argv);
 	exit(-1);
 }
-- 
2.9.3
