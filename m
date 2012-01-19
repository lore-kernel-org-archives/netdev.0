From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] using NLM_F_DUMP flag constant in libnetlink.c
Date: Thu, 19 Jan 2012 20:31:08 +0900 (JST)
Message-ID: <20120119.203108.460927494189100272.yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501Ab2ASLbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 06:31:10 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q0JBV9PK007871
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 06:31:09 -0500
Received: from localhost (beach.nrt.redhat.com [10.64.200.71])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q0JBV83T006596
	for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 06:31:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is trivial patch for libnetlink.c in iproute2.

In iproute2/include/linux/netlink.h NLM_F_DUMP is defines as:

   #define NLM_F_DUMP	(NLM_F_ROOT|NLM_F_MATCH)

It is not used in libnetlink.c. If used, the code becomes a bit easier
to read.



Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index c8fc4ef..c581e11 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -99,7 +99,7 @@ int rtnl_wilddump_request(struct rtnl_handle *rth, int family, int type)
 	memset(&req, 0, sizeof(req));
 	req.nlh.nlmsg_len = sizeof(req);
 	req.nlh.nlmsg_type = type;
-	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
+	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
 	req.nlh.nlmsg_pid = 0;
 	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
 	req.g.rtgen_family = family;
@@ -162,7 +162,7 @@ int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req, int len)
 
 	nlh.nlmsg_len = NLMSG_LENGTH(len);
 	nlh.nlmsg_type = type;
-	nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
+	nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
 	nlh.nlmsg_pid = 0;
 	nlh.nlmsg_seq = rth->dump = ++rth->seq;
