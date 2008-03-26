From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: Fix classifier help
Date: Wed, 26 Mar 2008 07:40:03 +0100
Message-ID: <47E9EFC3.3000600@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040702010307010600030500"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:15494 "EHLO
	viefep14-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750700AbYCZGkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 02:40:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040702010307010600030500
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------040702010307010600030500
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit c504ffd627ac211eebf5ed34ef0fbfd7f1dbb347
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Mar 26 07:38:43 2008 +0100

    [IPROUTE]: Fix classifier help

    The new check whether the user has specified a protocol makes
    "ip filter <type> help" fails with "protocol is required".

    This could be fixed by moving it further down, but a more user-friendly
    way it to simply use ETH_P_ALL as default if nothing is specified.

    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index d70c656..6701f9a 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -54,7 +54,8 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 	} req;
 	struct filter_util *q = NULL;
 	__u32 prio = 0;
-	__u32 protocol = 0;
+	__u32 protocol = ETH_P_ALL;
+	int protocol_set = 0;
 	char *fhandle = NULL;
 	char  d[16];
 	char  k[16];
@@ -106,11 +107,12 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 		} else if (matches(*argv, "protocol") == 0) {
 			__u16 id;
 			NEXT_ARG();
-			if (protocol)
+			if (protocol_set)
 				duparg("protocol", *argv);
 			if (ll_proto_a2n(&id, *argv))
 				invarg(*argv, "invalid protocol");
 			protocol = id;
+			protocol_set = 1;
 		} else if (matches(*argv, "estimator") == 0) {
 			if (parse_estimator(&argc, &argv, &est) < 0)
 				return -1;
@@ -127,11 +129,6 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 		argc--; argv++;
 	}
 
-	if (!protocol) {
-		fprintf(stderr, "\"protocol\" is required.\n");
-		return -1;
-	}
-
 	req.t.tcm_info = TC_H_MAKE(prio<<16, protocol);
 
 	if (k[0])

--------------040702010307010600030500--
