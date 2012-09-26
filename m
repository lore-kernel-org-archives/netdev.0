From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 07/11] nfnetlink_cttimeout: pass nfnetlink_cttimeout module to netlink_dump_start
Date: Wed, 26 Sep 2012 12:52:16 +0800
Message-ID: <1348635140-20225-7-git-send-email-gaofeng@cn.fujitsu.com>
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
 net/netfilter/nfnetlink_cttimeout.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index cdecbc8..bc3e730 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -248,6 +248,8 @@ cttimeout_get_timeout(struct sock *ctnl, struct sk_buff *skb,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = ctnl_timeout_dump,
+			.done = netlink_dump_done,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
-- 
1.7.7.6

