From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 1/3] Expose rtnl_link_ops_get()
Date: Fri, 22 Jan 2010 13:09:50 -0800
Message-ID: <1264194592-7529-2-git-send-email-danms@us.ibm.com>
References: <1264194592-7529-1-git-send-email-danms@us.ibm.com>
Cc: netdev@vger.kernel.org, orenl@librato.com
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stein.danplanet.com ([71.245.107.83]:35729 "EHLO
	stein.danplanet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473Ab0AVVLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 16:11:14 -0500
In-Reply-To: <1264194592-7529-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Smith <danms@us.ibm.com>
Cc: netdev@vger.kernel.org
---
 include/net/rtnetlink.h |    1 +
 net/core/rtnetlink.c    |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index c3aa044..a165769 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -82,6 +82,7 @@ extern void	rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops);
 extern int	rtnl_link_register(struct rtnl_link_ops *ops);
 extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
 
+extern const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind);
 extern struct net_device *rtnl_create_link(struct net *net, char *ifname,
 		const struct rtnl_link_ops *ops, struct nlattr *tb[]);
 extern const struct nla_policy ifla_policy[IFLA_MAX+1];
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index eb42873..2b2150c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -325,7 +325,7 @@ void rtnl_link_unregister(struct rtnl_link_ops *ops)
 
 EXPORT_SYMBOL_GPL(rtnl_link_unregister);
 
-static const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind)
+const struct rtnl_link_ops *rtnl_link_ops_get(const char *kind)
 {
 	const struct rtnl_link_ops *ops;
 
-- 
1.6.2.5

