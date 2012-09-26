From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 02/11] inet_diag: pass inet_diag module to netlink_dump_start
Date: Wed, 26 Sep 2012 12:52:11 +0800
Message-ID: <1348635140-20225-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	pablo@netfilter.org, steffen.klassert@secunet.com,
	linux-crypto@vger.kernel.org, jengelh@inai.de,
	stephen.hemminger@vyatta.com, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use proper netlink_dump_control.done and .module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/inet_diag.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 570e61f..36d4be5 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -972,6 +972,8 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 		{
 			struct netlink_dump_control c = {
 				.dump = inet_diag_dump_compat,
+				.done = netlink_dump_done,
+				.module = THIS_MODULE,
 			};
 			return netlink_dump_start(net->diag_nlsk, skb, nlh, &c);
 		}
@@ -1001,6 +1003,8 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		{
 			struct netlink_dump_control c = {
 				.dump = inet_diag_dump,
+				.done = netlink_dump_done,
+				.module = THIS_MODULE,
 			};
 			return netlink_dump_start(net->diag_nlsk, skb, h, &c);
 		}
-- 
1.7.7.6

