From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 06/11] nfnetlink_cthelper: pass nfnetlink_cthelper module to netlink_dump_start
Date: Wed, 26 Sep 2012 12:52:15 +0800
Message-ID: <1348635140-20225-6-git-send-email-gaofeng@cn.fujitsu.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	pablo@netfilter.org, steffen.klassert@secunet.com,
	linux-crypto@vger.kernel.org, jengelh@inai.de,
	stephen.hemminger@vyatta.com, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:27694 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751585Ab2IZEww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 00:52:52 -0400
In-Reply-To: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use proper netlink_dump_control.done and .module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nfnetlink_cthelper.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index d683619..117343f 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -501,6 +501,8 @@ nfnl_cthelper_get(struct sock *nfnl, struct sk_buff *skb,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = nfnl_cthelper_dump_table,
+			.done = netlink_dump_done,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(nfnl, skb, nlh, &c);
 	}
-- 
1.7.7.6
