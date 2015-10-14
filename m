From: Ronen Arad <ronen.arad@intel.com>
Subject: [PATCH net-next 2/4] bridge: br_af_ops add br_get_link_af_size_filtered
Date: Tue, 13 Oct 2015 22:58:32 -0700
Message-ID: <1444802314-28830-3-git-send-email-ronen.arad@intel.com>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Cc: Ronen Arad <ronen.arad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30704 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501AbbJNF70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 01:59:26 -0400
In-Reply-To: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide get_af_size_filtered (set to br_get_link_af_size_filtered)
in br_af_ops for proper filtering mask aware sizing of AF_BRIDGE
attributes. This is an optimization of netlink message size when
-c[compressvlans] option is entered for iproute2's bridge command.
Optimization will get into effect with rtnetlink change in the next
patch of this set.

Signed-off-by: Ronen Arad <ronen.arad@intel.com>
---
 net/bridge/br_netlink.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 94b4de8..d900881 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1235,8 +1235,9 @@ static size_t br_get_link_af_size(const struct net_device *dev)
 }
 
 static struct rtnl_af_ops br_af_ops __read_mostly = {
-	.family			= AF_BRIDGE,
-	.get_link_af_size	= br_get_link_af_size,
+	.family				= AF_BRIDGE,
+	.get_link_af_size		= br_get_link_af_size,
+	.get_link_af_size_filtered	= br_get_link_af_size_filtered,
 };
 
 struct rtnl_link_ops br_link_ops __read_mostly = {
-- 
2.1.0
