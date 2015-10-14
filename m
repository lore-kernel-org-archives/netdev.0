From: Ronen Arad <ronen.arad@intel.com>
Subject: [PATCH net-next 1/4] rtnetlink: Add get_link_af_size_filtered to rtnl_af_ops
Date: Tue, 13 Oct 2015 22:58:31 -0700
Message-ID: <1444802314-28830-2-git-send-email-ronen.arad@intel.com>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Cc: Ronen Arad <ronen.arad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30704 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbbJNF7W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 01:59:22 -0400
In-Reply-To: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

get_link_af_size_filtered() - a filtering-mask aware alternative
function is added to struct rtnl_af_ops in order to allow for
"rightsizing" the IFLA_AF_SPEC calculation in if_nlmsg_size().
This significantly reduces the message size when at least one netdev has
large number of VLANs.

Signed-off-by: Ronen Arad <ronen.arad@intel.com>
---
 include/net/rtnetlink.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index aff6ceb..96df9bb 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -130,6 +130,8 @@ struct rtnl_af_ops {
 						    const struct nlattr *attr);
 	int			(*set_link_af)(struct net_device *dev,
 					       const struct nlattr *attr);
+	size_t			(*get_link_af_size_filtered)(const struct net_device *dev,
+							     u32 ext_filter_mask);
 };
 
 void __rtnl_af_unregister(struct rtnl_af_ops *ops);
-- 
2.1.0
