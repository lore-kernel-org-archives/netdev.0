From: Phil Sutter <phil@nwl.cc>
Subject: [iproute2 PATCH] ip-link: do not support 'ip link add dev help'
Date: Mon, 21 Sep 2015 21:33:01 +0200
Message-ID: <1442863981-19112-1-git-send-email-phil@nwl.cc>
References: <CAK8ArgOM2Vyr4DJO73wzhgFFbGMm9p+XMGcD2JAWeZ8G+_3PSw@mail.gmail.com>
Cc: netdev@vger.kernel.org, Wilhelm Wijkander <lists@0x5e.se>,
	Vadim Kochan <vadim4j@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:48156 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756402AbbIUTdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 15:33:03 -0400
In-Reply-To: <CAK8ArgOM2Vyr4DJO73wzhgFFbGMm9p+XMGcD2JAWeZ8G+_3PSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0532555 ('Support "ip link add help" for rtnl_link API') added a
check for specified help parameter. Though due to the place where it has
been added to, it is not possible anymore to force a given parameter to
be interpreted as interface name by prefixing it with 'dev '. Fix this
by forcing whatever follows 'dev' to be presumed as interface name.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 97f46cd..1c45205 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -647,11 +647,11 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			addattr8(&req->n, sizeof(*req), IFLA_PROTO_DOWN,
 				 proto_down);
 		} else {
-			if (strcmp(*argv, "dev") == 0)
-				NEXT_ARG();
-
 			if (matches(*argv, "help") == 0)
 				usage();
+
+			if (strcmp(*argv, "dev") == 0)
+				NEXT_ARG();
 			if (*dev)
 				duparg2("dev", *argv);
 			*dev = *argv;
-- 
2.1.2
