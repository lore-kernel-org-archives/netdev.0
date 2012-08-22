From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: [PATCH] iproute2: rtnl_wilddump_request: fix alignment for embedded platforms
Date: Wed, 22 Aug 2012 09:38:53 +0200
Message-ID: <1345621133-23583-1-git-send-email-ljaenicke@innominate.com>
Cc: Lutz Jaenicke <ljaenicke@innominate.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.innominate.com ([77.245.32.75]:40099 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756970Ab2HVHjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 03:39:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Platforms have different alignment requirements which need to be
fulfilled by the compiler. If the structure elements are already
4 byte (NLMGS_ALIGNTO) aligned by the compiler adding an explicit
padding element (align_rta) is not allowed.
Use __attribute__ ((aligned (NLMSG_ALIGNTO))) in order to achieve
the required alignment.
Experienced on ARM (xscale) with symptom
  netlink: 12 bytes leftover after parsing attributes

Signed-off-by: Lutz Jaenicke <ljaenicke@innominate.com>
---
 lib/libnetlink.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 8e8c8b9..05701ef 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -94,10 +94,9 @@ int rtnl_wilddump_request(struct rtnl_handle *rth, int family, int type)
 	struct {
 		struct nlmsghdr nlh;
 		struct rtgenmsg g;
-		__u16 align_rta;	/* attribute has to be 32bit aligned */
 		struct rtattr ext_req;
 		__u32 ext_filter_mask;
-	} req;
+	} req __attribute__ ((aligned (NLMSG_ALIGNTO)));
 
 	memset(&req, 0, sizeof(req));
 	req.nlh.nlmsg_len = sizeof(req);
-- 
1.7.2.5
