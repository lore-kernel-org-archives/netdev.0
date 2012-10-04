From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [patch v3 02/11] inet_diag: pass inet_diag module to netlink_dump_start
Date: Thu, 4 Oct 2012 12:41:20 +0800
Message-ID: <1349325689-16104-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	pablo@netfilter.org, stephen.hemminger@vyatta.com, jengelh@inai.de,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set netlink_dump_control.module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/inet_diag.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 535584c..5ffd7bc 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -981,6 +981,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 		{
 			struct netlink_dump_control c = {
 				.dump = inet_diag_dump_compat,
+				.module = THIS_MODULE,
 			};
 			return netlink_dump_start(net->diag_nlsk, skb, nlh, &c);
 		}
@@ -1010,6 +1011,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		{
 			struct netlink_dump_control c = {
 				.dump = inet_diag_dump,
+				.module = THIS_MODULE,
 			};
 			return netlink_dump_start(net->diag_nlsk, skb, h, &c);
 		}
-- 
1.7.7.6
