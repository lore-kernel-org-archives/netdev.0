From: greearb@candelatech.com
Subject: [PATCH] net:  Report dev->promiscuity in netlink reports.
Date: Thu, 29 Mar 2012 15:51:30 -0700
Message-ID: <1333061490-4484-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36742 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760168Ab2C2Wvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 18:51:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

The standard ways of probing a device's promiscuity
(ifi_flags, for instance) does not report the actual
state of the device.  This patch adds dev->promiscuity
to the netlink netdevice report so that users can know
for certain if the device is acting PROMISC or not.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 4b24ff4... 2f4fa93... M	include/linux/if_link.h
:100644 100644 f965dce... 6f4983f... M	net/core/rtnetlink.c
 include/linux/if_link.h |    2 ++
 net/core/rtnetlink.c    |    3 +++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 4b24ff4..2f4fa93 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -138,6 +138,8 @@ enum {
 	IFLA_GROUP,		/* Group the device belongs to */
 	IFLA_NET_NS_FD,
 	IFLA_EXT_MASK,		/* Extended info mask, VFs, etc */
+	IFLA_PROMISCUITY,	/* Promiscuity count: > 0 means acts PROMISC */
+#define IFLA_PROMISCUITY IFLA_PROMISCUITY
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f965dce..6f4983f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -783,6 +783,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(4) /* IFLA_MTU */
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
+	       + nla_total_size(4) /* IFLA_PROMISCUITY */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(ext_filter_mask
@@ -899,6 +900,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
 	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
 	NLA_PUT_U32(skb, IFLA_GROUP, dev->group);
+	NLA_PUT_U32(skb, IFLA_PROMISCUITY, dev->promiscuity);
 
 	if (dev->ifindex != dev->iflink)
 		NLA_PUT_U32(skb, IFLA_LINK, dev->iflink);
@@ -1114,6 +1116,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
 	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
 	[IFLA_EXT_MASK]		= { .type = NLA_U32 },
+	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
 };
 EXPORT_SYMBOL(ifla_policy);
 
-- 
1.7.3.4
