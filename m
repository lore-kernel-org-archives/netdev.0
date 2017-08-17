From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 3/7] iproute: Fix for missing 'Oifs:' display
Date: Thu, 17 Aug 2017 19:09:27 +0200
Message-ID: <20170817170931.24089-4-phil@nwl.cc>
References: <20170817170931.24089-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47331 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753386AbdHQRKj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:10:39 -0400
In-Reply-To: <20170817170931.24089-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Covscan complained about dead code but after reading it, I assume the
author's intention was to prefix the interface list with 'Oifs: '.
Initializing first to 1 and setting it to 0 after above prefix was
printed should fix it.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index cb695ad4141a7..89caac124f489 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -624,7 +624,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 	if (tb[RTA_MULTIPATH]) {
 		struct rtnexthop *nh = RTA_DATA(tb[RTA_MULTIPATH]);
-		int first = 0;
+		int first = 1;
 
 		len = RTA_PAYLOAD(tb[RTA_MULTIPATH]);
 
@@ -634,10 +634,12 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (nh->rtnh_len > len)
 				break;
 			if (r->rtm_flags&RTM_F_CLONED && r->rtm_type == RTN_MULTICAST) {
-				if (first)
+				if (first) {
 					fprintf(fp, "Oifs: ");
-				else
+					first = 0;
+				} else {
 					fprintf(fp, " ");
+				}
 			} else
 				fprintf(fp, "%s\tnexthop ", _SL_);
 			if (nh->rtnh_len > sizeof(*nh)) {
-- 
2.13.1
