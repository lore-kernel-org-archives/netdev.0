From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] net/rtnetlink: remove unused sz_idx variable
Date: Sun, 10 Jan 2016 21:26:57 +0600
Message-ID: <1452439617-17860-1-git-send-email-kuleshovmail@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Kuleshov <kuleshovmail@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sz_idx variable is defined in the rtnetlink_rcv_msg(), but
not used anywhere. Let's remove it.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 net/core/rtnetlink.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 34ba7a0..e78e531 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3347,7 +3347,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	rtnl_doit_func doit;
-	int sz_idx, kind;
+	int kind;
 	int family;
 	int type;
 	int err;
@@ -3363,7 +3363,6 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return 0;
 
 	family = ((struct rtgenmsg *)nlmsg_data(nlh))->rtgen_family;
-	sz_idx = type>>2;
 	kind = type&3;
 
 	if (kind != 2 && !netlink_net_capable(skb, CAP_NET_ADMIN))
-- 
2.6.2.485.g1bc8fea
