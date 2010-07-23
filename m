From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] iproute2: filter routing entries based on clone flag
Date: Fri, 23 Jul 2010 15:36:08 +0200
Message-ID: <20100723133608.GA12942@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-40.dex002.intermedia.net ([64.78.21.127]:4054 "EHLO
	dhost002-40.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754506Ab0GWNv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 09:51:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before IPv6 routing cache entries were always displayed
if additional tables beside MAIN and LOCAL are installed.

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 ip/iproute.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 8252e18..fce7f33 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -160,14 +160,11 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (r->rtm_family == AF_INET6 && table != RT_TABLE_MAIN)
 		ip6_multiple_tables = 1;
 
+	if (filter.cloned == !(r->rtm_flags&RTM_F_CLONED))
+		return 0;
+
 	if (r->rtm_family == AF_INET6 && !ip6_multiple_tables) {
-		if (filter.cloned) {
-			if (!(r->rtm_flags&RTM_F_CLONED))
-				return 0;
-		}
 		if (filter.tb) {
-			if (!filter.cloned && r->rtm_flags&RTM_F_CLONED)
-				return 0;
 			if (filter.tb == RT_TABLE_LOCAL) {
 				if (r->rtm_type != RTN_LOCAL)
 					return 0;
@@ -179,10 +176,6 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			}
 		}
 	} else {
-		if (filter.cloned) {
-			if (!(r->rtm_flags&RTM_F_CLONED))
-				return 0;
-		}
 		if (filter.tb > 0 && filter.tb != table)
 			return 0;
 	}
-- 
1.7.0.4

