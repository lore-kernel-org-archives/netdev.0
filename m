From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [IPROUTE PATCH] libnetlink: Use ifinfomsg instead of rtgenmsg in
 rtnl_wilddump_req_filter
Date: Thu, 25 Apr 2013 15:07:10 -0700
Message-ID: <20130425220710.6520.32515.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	jeffrey.t.kirsher@intel.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19958 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932608Ab3DYWJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 18:09:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change corrects a kernel incompatibility that was resulting in the
ext_filter_mask not being correctly discovered by the kernel as it is buried
somewhere in the ifinfomsg.

Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 lib/libnetlink.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 04201cd..b17e1aa 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -99,7 +99,7 @@ int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int family, int type,
 {
 	struct {
 		struct nlmsghdr nlh;
-		struct rtgenmsg g;
+		struct ifinfomsg ifm;
 		/* attribute has to be NLMSG aligned */
 		struct rtattr ext_req __attribute__ ((aligned(NLMSG_ALIGNTO)));
 		__u32 ext_filter_mask;
@@ -111,7 +111,7 @@ int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int family, int type,
 	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
 	req.nlh.nlmsg_pid = 0;
 	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
-	req.g.rtgen_family = family;
+	req.ifm.ifi_family = family;
 
 	req.ext_req.rta_type = IFLA_EXT_MASK;
 	req.ext_req.rta_len = RTA_LENGTH(sizeof(__u32));
