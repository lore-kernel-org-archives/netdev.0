From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] Fix MAC address length check
Date: Wed, 22 Jun 2016 12:05:38 +0200
Message-ID: <1466589938-14448-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60373 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255AbcFVKST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 06:18:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot to change the variable in the conditional, too.

Fixes: 8fe58d58941f4 ("iplink: Check address length via netlink")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 68e5faea3581d..b1f8a37922f51 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -491,7 +491,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		} else if (matches(*argv, "address") == 0) {
 			NEXT_ARG();
 			addr_len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
-			if (len < 0)
+			if (addr_len < 0)
 				return -1;
 			addattr_l(&req->n, sizeof(*req), IFLA_ADDRESS, abuf, addr_len);
 		} else if (matches(*argv, "broadcast") == 0 ||
-- 
2.8.2
