From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] netpoll: fix a missing dev refcounting
Date: Thu, 17 Jan 2013 12:21:08 +0800
Message-ID: <1358396468-14938-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60535 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758393Ab3AQEVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 23:21:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__dev_get_by_name() doesn't refcount the network device,
so we have to do this by ourselves. Noticed by Eric.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a5ad1c1..a9b1004 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -1056,6 +1056,7 @@ int netpoll_setup(struct netpoll *np)
 		err = -ENODEV;
 		goto unlock;
 	}
+	dev_hold(ndev);
 
 	if (netdev_master_upper_dev_get(ndev)) {
 		np_err(np, "%s is a slave device, aborting\n", np->dev_name);
