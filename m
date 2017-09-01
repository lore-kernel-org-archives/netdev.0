From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] link_gre6: Print the tunnel's tclass setting
Date: Fri,  1 Sep 2017 16:08:09 +0200
Message-ID: <20170901140809.13230-3-phil@nwl.cc>
References: <20170901140809.13230-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46571 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdIAOIW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 10:08:22 -0400
In-Reply-To: <20170901140809.13230-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print the value analogous to flowlabel. While being at it, also break
the overlong lines to not exceed 80 characters boundary.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/link_gre6.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index 447ac5d78ab7b..78b5215c65037 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -462,7 +462,14 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
 		fprintf(f, "flowlabel inherit ");
 	else
-		fprintf(f, "flowlabel 0x%05x ", ntohl(flowinfo & IP6_FLOWINFO_FLOWLABEL));
+		fprintf(f, "flowlabel 0x%05x ",
+			ntohl(flowinfo & IP6_FLOWINFO_FLOWLABEL));
+
+	if (flags & IP6_TNL_F_USE_ORIG_TCLASS)
+		fprintf(f, "tclass inherit ");
+	else
+		fprintf(f, "tclass 0x%02x ",
+			ntohl(flowinfo & IP6_FLOWINFO_TCLASS) >> 20);
 
 	if (flags & IP6_TNL_F_RCV_DSCP_COPY)
 		fprintf(f, "dscp inherit ");
-- 
2.13.1
