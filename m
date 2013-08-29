From: Stephen Hemminger <stephen@networkplumber.org>
Subject: iproute2: add ability to filter neighbour discovery by protocol
Date: Thu, 29 Aug 2013 12:21:34 -0700
Message-ID: <20130829122134.0d5a6f72@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:61712 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820Ab3H2TVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 15:21:38 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so860310pbb.6
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 12:21:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Useful to be able to monitor arp and IPv6 nd seperately.
Default is both.
---
 ip/ipmonitor.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 4895390..70f2a7a 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -36,7 +36,6 @@ static void usage(void)
 	exit(-1);
 }
 
-
 static int accept_msg(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n, void *arg)
 {
@@ -88,6 +87,13 @@ static int accept_msg(const struct sockaddr_nl *who,
 	}
 	if (n->nlmsg_type == RTM_NEWNEIGH || n->nlmsg_type == RTM_DELNEIGH ||
 	    n->nlmsg_type == RTM_GETNEIGH) {
+		if (preferred_family) {
+			struct ndmsg *r = NLMSG_DATA(n);
+
+			if (r->ndm_family != preferred_family)
+				return 0;
+		}
+
 		if (prefix_banner)
 			fprintf(fp, "[NEIGH]");
 		print_neigh(who, n, arg);
-- 
1.7.10.4
