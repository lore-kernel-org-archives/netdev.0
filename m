From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC PATCH] iproute2: Add flag to indicate extended dump info
Date: Fri, 10 Feb 2012 07:18:05 -0800
Message-ID: <20120210151804.4175.12859.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24715 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529Ab2BJPR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 10:17:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add flag to the ip link dump command to indicate to the kernel that
the application is requesting the extended interface information such
as VFs.  The kernel will take this flag as an implicit indication that
the application has allocated a 16K or larger buffer, which is what
the 'ip' command in fact does.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/netlink.h |    1 +
 lib/libnetlink.c        |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 5c4f087..f913797 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -59,6 +59,7 @@ struct nlmsghdr {
 #define NLM_F_MATCH	0x200	/* return all matching	*/
 #define NLM_F_ATOMIC	0x400	/* atomic GET		*/
 #define NLM_F_DUMP	(NLM_F_ROOT|NLM_F_MATCH)
+#define NLM_F_EXT	0x800   /* Get extended interface info such as VFs */
 
 /* Modifiers to NEW request */
 #define NLM_F_REPLACE	0x100	/* Override existing		*/
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index c581e11..f29da3d 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -99,7 +99,7 @@ int rtnl_wilddump_request(struct rtnl_handle *rth, int family, int type)
 	memset(&req, 0, sizeof(req));
 	req.nlh.nlmsg_len = sizeof(req);
 	req.nlh.nlmsg_type = type;
-	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
+	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST|NLM_F_EXT;
 	req.nlh.nlmsg_pid = 0;
 	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
 	req.g.rtgen_family = family;
