From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [patch v2 03/11] unix_diag: pass unix_diag module to netlink_dump_start
Date: Wed, 26 Sep 2012 16:41:20 +0800
Message-ID: <1348648888-24943-3-git-send-email-gaofeng@cn.fujitsu.com>
References: <1348648888-24943-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	pablo@netfilter.org, stephen.hemminger@vyatta.com, jengelh@inai.de,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1348648888-24943-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set netlink_dump_control.done and .module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/unix/diag.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index 750b134..5e09553 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -299,6 +299,8 @@ static int unix_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 	if (h->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = unix_diag_dump,
+			.done = netlink_dump_done,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(net->diag_nlsk, skb, h, &c);
 	} else
-- 
1.7.7.6
