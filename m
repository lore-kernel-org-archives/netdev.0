From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] selinux/nlmsg: add a build time check for rtnl/xfrm cmds
Date: Mon, 13 Apr 2015 15:20:37 +0200
Message-ID: <1428931237-22679-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a new rtnl or xfrm command is added, this part of the code is frequently
missing. Let's help the developer with a build time test.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 security/selinux/nlmsgtab.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 30594bfa5fb1..2bbb41822d8e 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -153,6 +153,8 @@ int selinux_nlmsg_lookup(u16 sclass, u16 nlmsg_type, u32 *perm)
 
 	switch (sclass) {
 	case SECCLASS_NETLINK_ROUTE_SOCKET:
+		/* RTM_MAX always point to RTM_SETxxxx, ie RTM_NEWxxx + 3 */
+		BUILD_BUG_ON(RTM_MAX != (RTM_NEWNSID + 3));
 		err = nlmsg_perm(nlmsg_type, perm, nlmsg_route_perms,
 				 sizeof(nlmsg_route_perms));
 		break;
@@ -163,6 +165,7 @@ int selinux_nlmsg_lookup(u16 sclass, u16 nlmsg_type, u32 *perm)
 		break;
 
 	case SECCLASS_NETLINK_XFRM_SOCKET:
+		BUILD_BUG_ON(XFRM_MSG_MAX != XFRM_MSG_MAPPING);
 		err = nlmsg_perm(nlmsg_type, perm, nlmsg_xfrm_perms,
 				 sizeof(nlmsg_xfrm_perms));
 		break;
-- 
2.2.2
