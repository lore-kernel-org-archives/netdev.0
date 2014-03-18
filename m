From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/6] netpoll: Don't allow on devices that perform their own xmit locking
Date: Mon, 17 Mar 2014 23:25:51 -0700
Message-ID: <87wqfsf2fk.fsf_-_@xmission.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58300 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaCRGZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 02:25:57 -0400
In-Reply-To: <87iorcgh5d.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 17 Mar 2014 23:22:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There are strong and reasonable assumptions in the netpoll code that the
transmit code for network devices will not perform their own locking,
that can easily lead to deadlock if the assumptions are violated.

Document those assumptions by verifying the network device on which
netpoll is enabled does not have NETIF_F_LLTX set in netdev->features.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 825200fcb0ff..a9abb195a2c3 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -606,6 +606,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 	INIT_WORK(&np->cleanup_work, netpoll_async_cleanup);
 
 	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
+	    (ndev->features & NETIF_F_LLTX) ||
 	    !ndev->netdev_ops->ndo_poll_controller) {
 		np_err(np, "%s doesn't support polling, aborting\n",
 		       np->dev_name);
-- 
1.7.5.4
