From: Asbjoern Sloth Toennesen <ast@fiberby.net>
Subject: [PATCH] rtnetlink: rtnl_bridge_getlink: Call nlmsg_find_attr() with ifinfomsg header
Date: Mon, 12 Aug 2013 16:30:09 +0000
Message-ID: <1376325009-8399-1-git-send-email-ast@fiberby.net>
References: <52090C26.4090001@fiberby.net>
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52090C26.4090001@fiberby.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the iproute2 command `bridge vlan show`, after switching from
rtgenmsg to ifinfomsg.

Signed-off-by: Asbjoern Sloth Toennesen <ast@fiberby.net>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 3de7408..a043171 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2384,7 +2384,7 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 	struct nlattr *extfilt;
 	u32 filter_mask = 0;
 
-	extfilt = nlmsg_find_attr(cb->nlh, sizeof(struct rtgenmsg),
+	extfilt = nlmsg_find_attr(cb->nlh, sizeof(struct ifinfomsg),
 				  IFLA_EXT_MASK);
 	if (extfilt)
 		filter_mask = nla_get_u32(extfilt);
-- 
1.8.4.rc1
