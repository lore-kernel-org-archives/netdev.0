From: David Forster <dforster@brocade.com>
Subject: [PATCH iproute2] ip6tunnel: Align ipv6 tunnel key display with ipv4
Date: Tue, 10 Jan 2017 10:45:54 +0000
Message-ID: <1484045154-19128-1-git-send-email-dforster@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dforster@brocade.com>
To: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:40906 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1765533AbdAJKqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 05:46:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show ipv6 tunnel keys on presence of GRE_KEY flag for tunnel types
other than GRE. Aligns ipv6 behaviour with ipv4.

Signed-off-by: dforster@brocade.com
---
 ip/ip6tunnel.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index b1c0ae6..b4a7def 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -111,16 +111,17 @@ static void print_tunnel(struct ip6_tnl_parm2 *p)
 	if (p->flags & IP6_TNL_F_RCV_DSCP_COPY)
 		printf(" dscp inherit");
 
-	if (p->proto == IPPROTO_GRE) {
-		if ((p->i_flags & GRE_KEY) && (p->o_flags & GRE_KEY) && p->o_key == p->i_key)
-			printf(" key %u", ntohl(p->i_key));
-		else if ((p->i_flags | p->o_flags) & GRE_KEY) {
-			if (p->i_flags & GRE_KEY)
-				printf(" ikey %u", ntohl(p->i_key));
-			if (p->o_flags & GRE_KEY)
-				printf(" okey %u", ntohl(p->o_key));
-		}
+	if ((p->i_flags & GRE_KEY) && (p->o_flags & GRE_KEY) &&
+	    p->o_key == p->i_key)
+		printf(" key %u", ntohl(p->i_key));
+	else {
+		if (p->i_flags & GRE_KEY)
+			printf(" ikey %u", ntohl(p->i_key));
+		if (p->o_flags & GRE_KEY)
+			printf(" okey %u", ntohl(p->o_key));
+	}
 
+	if (p->proto == IPPROTO_GRE) {
 		if (p->i_flags & GRE_SEQ)
 			printf("%s  Drop packets out of sequence.", _SL_);
 		if (p->i_flags & GRE_CSUM)
-- 
2.1.4
