From: Julien Gomes <julien@arista.com>
Subject: [PATCH net-next v2 1/4] rtnetlink: add NEWCACHEREPORT message type
Date: Mon, 19 Jun 2017 13:44:14 -0700
Message-ID: <20170619204417.13230-2-julien@arista.com>
References: <20170619204417.13230-1-julien@arista.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sharpd@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        Julien Gomes <julien@arista.com>
To: davem@davemloft.net, nikolay@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619204417.13230-1-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
