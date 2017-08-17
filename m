From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 5/5] tipc/bearer: Fix resource leak in error path
Date: Thu, 17 Aug 2017 19:09:31 +0200
Message-ID: <20170817170931.24435-6-phil@nwl.cc>
References: <20170817170931.24435-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42709 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753425AbdHQRLE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:11:04 -0400
In-Reply-To: <20170817170931.24435-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tipc/bearer.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tipc/bearer.c b/tipc/bearer.c
index 810344f672af1..c3d4491f8f6ef 100644
--- a/tipc/bearer.c
+++ b/tipc/bearer.c
@@ -163,6 +163,7 @@ static int nl_add_udp_enable_opts(struct nlmsghdr *nlh, struct opt *opts,
 	if (!remip) {
 		if (generate_multicast(loc->ai_family, buf, sizeof(buf))) {
 			fprintf(stderr, "Failed to generate multicast address\n");
+			freeaddrinfo(loc);
 			return -EINVAL;
 		}
 		remip = buf;
@@ -177,6 +178,8 @@ static int nl_add_udp_enable_opts(struct nlmsghdr *nlh, struct opt *opts,
 
 	if (rem->ai_family != loc->ai_family) {
 		fprintf(stderr, "UDP local and remote AF mismatch\n");
+		freeaddrinfo(rem);
+		freeaddrinfo(loc);
 		return -EINVAL;
 	}
 
-- 
2.13.1
