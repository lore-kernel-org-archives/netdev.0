From: <Narendra_K@Dell.com>
Subject: [RFC PATCH net-next] net: Include phys_port identifier in the
 RTM_NEWLINK message
Date: Fri, 28 Jun 2013 21:04:43 +0530
Message-ID: <20130628153424.GA4340@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <bhutchings@solarflare.com>, <john.r.fastabend@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:1335 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab3F1PgF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 11:36:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new netlink attribute 'IFLA_PHYS_PORT' to identify
the 'phys_port' identifier and includes the 'phys_port' identifier
in the RTM_NEWLINK message.

Signed-off-by: Narendra K <narendra_k@dell.com>
---
 include/uapi/linux/if_link.h | 1 +
 net/core/rtnetlink.c         | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 03f6170..6dc4476 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -143,6 +143,7 @@ enum {
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
+	IFLA_PHYS_PORT,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9007533..ade66a3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -751,6 +751,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(sizeof(struct rtnl_link_stats64))
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_BROADCAST */
+	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_PHYS_PORT */
 	       + nla_total_size(4) /* IFLA_TXQLEN */
 	       + nla_total_size(4) /* IFLA_WEIGHT */
 	       + nla_total_size(4) /* IFLA_MTU */
@@ -913,6 +914,12 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			goto nla_put_failure;
 	}
 
+	if (dev->phys_port.port_id_len) {
+		if (nla_put(skb, IFLA_PHYS_PORT, dev->phys_port.port_id_len,
+			    dev->phys_port.port_id))
+			goto nla_put_failure;
+	}
+
 	attr = nla_reserve(skb, IFLA_STATS,
 			sizeof(struct rtnl_link_stats));
 	if (attr == NULL)
-- 
1.8.0.1

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
