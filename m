From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip-route: Prevent some double spaces in output
Date: Tue, 23 Aug 2016 11:52:45 +0200
Message-ID: <1471945965-17331-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35222 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757454AbcHWJw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 05:52:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code is a bit messy, as it starts with space after text and at some
point switches to space before text. But either way, printing space
before *and* after text almost certainly leads to printing more
whitespace than necessary.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 3da23af9fdffc..4d7da0233046d 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -417,22 +417,22 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "dev %s ", ll_index_to_name(*(int *)RTA_DATA(tb[RTA_OIF])));
 
 	if (table && (table != RT_TABLE_MAIN || show_details > 0) && !filter.tb)
-		fprintf(fp, " table %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
+		fprintf(fp, "table %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
 	if (!(r->rtm_flags&RTM_F_CLONED)) {
 		if ((r->rtm_protocol != RTPROT_BOOT || show_details > 0) && filter.protocolmask != -1)
-			fprintf(fp, " proto %s ", rtnl_rtprot_n2a(r->rtm_protocol, b1, sizeof(b1)));
+			fprintf(fp, "proto %s ", rtnl_rtprot_n2a(r->rtm_protocol, b1, sizeof(b1)));
 		if ((r->rtm_scope != RT_SCOPE_UNIVERSE || show_details > 0) && filter.scopemask != -1)
-			fprintf(fp, " scope %s ", rtnl_rtscope_n2a(r->rtm_scope, b1, sizeof(b1)));
+			fprintf(fp, "scope %s ", rtnl_rtscope_n2a(r->rtm_scope, b1, sizeof(b1)));
 	}
 	if (tb[RTA_PREFSRC] && filter.rprefsrc.bitlen != host_len) {
 		/* Do not use format_host(). It is our local addr
 		   and symbolic name will not be useful.
 		 */
-		fprintf(fp, " src %s ",
+		fprintf(fp, "src %s ",
 			rt_addr_n2a_rta(r->rtm_family, tb[RTA_PREFSRC]));
 	}
 	if (tb[RTA_PRIORITY])
-		fprintf(fp, " metric %u ", rta_getattr_u32(tb[RTA_PRIORITY]));
+		fprintf(fp, "metric %u ", rta_getattr_u32(tb[RTA_PRIORITY]));
 	if (r->rtm_flags & RTNH_F_DEAD)
 		fprintf(fp, "dead ");
 	if (r->rtm_flags & RTNH_F_ONLINK)
@@ -450,9 +450,9 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 		if (mark) {
 			if (mark >= 16)
-				fprintf(fp, " mark 0x%x", mark);
+				fprintf(fp, "mark 0x%x ", mark);
 			else
-				fprintf(fp, " mark %u", mark);
+				fprintf(fp, "mark %u ", mark);
 		}
 	}
 
-- 
2.8.2
