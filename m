From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 1/2] if_link: add client name to port profile
Date: Fri,  3 Oct 2014 04:11:22 +0530
Message-ID: <1412289683-8278-2-git-send-email-_govind@gmx.com>
References: <1412289683-8278-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:54496 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbaJBWph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 18:45:37 -0400
In-Reply-To: <1412289683-8278-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds client name to port profile.

This is used by netlink client to send the client name in port profile.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 include/uapi/linux/if_link.h | 1 +
 net/core/rtnetlink.c         | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 0bdb77e..6ae0b0b 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -512,6 +512,7 @@ enum {
 	IFLA_PORT_HOST_UUID,		/* binary UUID */
 	IFLA_PORT_REQUEST,		/* __u8 */
 	IFLA_PORT_RESPONSE,		/* __u16, output only */
+	IFLA_PORT_VMNAME,		/* vm-name used by port profile */
 	__IFLA_PORT_MAX,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a688268..116d647 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1238,6 +1238,8 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 				    .len = PORT_UUID_MAX },
 	[IFLA_PORT_REQUEST]	= { .type = NLA_U8, },
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
+	[IFLA_PORT_VMNAME]	= { .type = NLA_STRING,
+				    .len = PORT_PROFILE_MAX },
 };
 
 static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
-- 
2.1.0
