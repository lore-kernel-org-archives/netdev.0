From: Julien Gomes <julien@arista.com>
Subject: [PATCH net-next 1/3] rtnetlink: add NEWCACHEREPORT message type
Date: Tue, 13 Jun 2017 10:08:20 -0700
Message-ID: <20170613170822.16310-2-julien@arista.com>
References: <20170613170822.16310-1-julien@arista.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        nikolay@cumulusnetworks.com, Julien Gomes <julien@arista.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:60492 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753389AbdFMRRB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:17:01 -0400
In-Reply-To: <20170613170822.16310-1-julien@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New NEWCACHEREPORT message type to be used for cache reports sent
via Netlink, effectively allowing splitting cache report reception from
mroute programming.

Suggested-by: Ryan Halbrook <halbrook@arista.com>
Signed-off-by: Julien Gomes <julien@arista.com>
---
 include/uapi/linux/rtnetlink.h | 3 +++
 security/selinux/nlmsgtab.c    | 3 ++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 564790e854f7..cd1afb900929 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -146,6 +146,9 @@ enum {
 	RTM_GETSTATS = 94,
 #define RTM_GETSTATS RTM_GETSTATS
 
+	RTM_NEWCACHEREPORT = 96,
+#define RTM_NEWCACHEREPORT RTM_NEWCACHEREPORT
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 5aeaf30b7a13..7b7433a1a34c 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -79,6 +79,7 @@ static const struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_GETNSID,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_NEWSTATS,		NETLINK_ROUTE_SOCKET__NLMSG_READ },
 	{ RTM_GETSTATS,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_NEWCACHEREPORT,	NETLINK_ROUTE_SOCKET__NLMSG_READ },
 };
 
 static const struct nlmsg_perm nlmsg_tcpdiag_perms[] =
@@ -158,7 +159,7 @@ int selinux_nlmsg_lookup(u16 sclass, u16 nlmsg_type, u32 *perm)
 	switch (sclass) {
 	case SECCLASS_NETLINK_ROUTE_SOCKET:
 		/* RTM_MAX always point to RTM_SETxxxx, ie RTM_NEWxxx + 3 */
-		BUILD_BUG_ON(RTM_MAX != (RTM_NEWSTATS + 3));
+		BUILD_BUG_ON(RTM_MAX != (RTM_NEWCACHEREPORT + 3));
 		err = nlmsg_perm(nlmsg_type, perm, nlmsg_route_perms,
 				 sizeof(nlmsg_route_perms));
 		break;
-- 
2.13.1
