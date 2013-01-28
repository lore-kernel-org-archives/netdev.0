From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v2 2/2] netpoll: use the net namespace of current process instead of init_net
Date: Mon, 28 Jan 2013 09:55:21 +0800
Message-ID: <1359338121-10897-2-git-send-email-amwang@redhat.com>
References: <1359338121-10897-1-git-send-email-amwang@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756484Ab3A1Bzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 20:55:36 -0500
In-Reply-To: <1359338121-10897-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This will allow us to setup netconsole in a different namespace
rather than where init_net is.

Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a6f39b6..331ccb9 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -1049,8 +1049,10 @@ int netpoll_setup(struct netpoll *np)
 	int err;
 
 	rtnl_lock();
-	if (np->dev_name)
-		ndev = __dev_get_by_name(&init_net, np->dev_name);
+	if (np->dev_name) {
+		struct net *net = current->nsproxy->net_ns;
+		ndev = __dev_get_by_name(net, np->dev_name);
+	}
 	if (!ndev) {
 		np_err(np, "%s doesn't exist, aborting\n", np->dev_name);
 		err = -ENODEV;
