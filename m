From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] bridge: remove oflags from setlink/dellink.
Date: Mon, 19 Jan 2015 11:45:04 +0200
Message-ID: <1421660704-5122-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	hemminger@vyatta.com, Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9708 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713AbbASFxs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 00:53:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 02dba4388d16 ("bridge: fix setlink/dellink notifications") removed usage of oflags in 
both rtnl_bridge_setlink() and rtnl_bridge_dellink() methods. This patch removes this variable as it is no 
longer needed.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 net/core/rtnetlink.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 0e26b9f..47b39f3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2918,7 +2918,7 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct net_device *dev;
 	struct nlattr *br_spec, *attr = NULL;
 	int rem, err = -EOPNOTSUPP;
-	u16 oflags, flags = 0;
+	u16 flags = 0;
 	bool have_flags = false;
 
 	if (nlmsg_len(nlh) < sizeof(*ifm))
@@ -2948,8 +2948,6 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 	}
 
-	oflags = flags;
-
 	if (!flags || (flags & BRIDGE_FLAGS_MASTER)) {
 		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 
@@ -2993,7 +2991,7 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct net_device *dev;
 	struct nlattr *br_spec, *attr = NULL;
 	int rem, err = -EOPNOTSUPP;
-	u16 oflags, flags = 0;
+	u16 flags = 0;
 	bool have_flags = false;
 
 	if (nlmsg_len(nlh) < sizeof(*ifm))
@@ -3023,8 +3021,6 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 	}
 
-	oflags = flags;
-
 	if (!flags || (flags & BRIDGE_FLAGS_MASTER)) {
 		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 
-- 
1.9.3
