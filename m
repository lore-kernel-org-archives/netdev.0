From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 3/6] ip neigh: Add support for keyword
Date: Mon, 27 Jun 2016 11:50:58 -0700
Message-ID: <1467053461-16147-4-git-send-email-dsa@cumulusnetworks.com>
References: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34096 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbcF0SvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:51:11 -0400
Received: by mail-pa0-f43.google.com with SMTP id bz2so61468185pad.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:51:11 -0700 (PDT)
In-Reply-To: <1467053461-16147-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vrf keyword to 'ip neigh' commands. Allows listing neighbor
entries for all links associated with a given VRF.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipneigh.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 4ddb747e2086..3e444712645f 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -48,7 +48,8 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip neigh { add | del | change | replace }\n"
 			"                { ADDR [ lladdr LLADDR ] [ nud STATE ] | proxy ADDR } [ dev DEV ]\n");
-	fprintf(stderr, "       ip neigh { show | flush } [ proxy ] [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n\n");
+	fprintf(stderr, "       ip neigh { show | flush } [ proxy ] [ to PREFIX ] [ dev DEV ] [ nud STATE ]\n");
+	fprintf(stderr, "                                 [ vrf NAME ]\n\n");
 	fprintf(stderr, "STATE := { permanent | noarp | stale | reachable | none |\n"
 			"           incomplete | delay | probe | failed }\n");
 	exit(-1);
@@ -385,6 +386,17 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 				invarg("Device does not exist\n", *argv);
 			addattr32(&req.n, sizeof(req), NDA_MASTER, ifindex);
 			filter.master = ifindex;
+		} else if (strcmp(*argv, "vrf") == 0) {
+			int ifindex;
+
+			NEXT_ARG();
+			ifindex = ll_name_to_index(*argv);
+			if (!ifindex)
+				invarg("Not a valid VRF name\n", *argv);
+			if (!name_is_vrf(*argv))
+				invarg("Not a valid VRF name\n", *argv);
+			addattr32(&req.n, sizeof(req), NDA_MASTER, ifindex);
+			filter.master = ifindex;
 		} else if (strcmp(*argv, "unused") == 0) {
 			filter.unused_only = 1;
 		} else if (strcmp(*argv, "nud") == 0) {
-- 
2.1.4
