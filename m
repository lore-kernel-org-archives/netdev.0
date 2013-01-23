From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] netpoll: fix an uninitialized variable
Date: Wed, 23 Jan 2013 11:39:11 +0800
Message-ID: <1358912351-14835-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145Ab3AWDjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 22:39:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Fengguang reported:

   net/core/netpoll.c: In function 'netpoll_setup':
   net/core/netpoll.c:1049:6: warning: 'err' may be used uninitialized in this function [-Wmaybe-uninitialized]

in !CONFIG_IPV6 case, we may error out without initializing
'err'.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a9b1004..e2f79a1 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -1140,6 +1140,7 @@ int netpoll_setup(struct netpoll *np)
 #else
 			np_err(np, "IPv6 is not supported %s, aborting\n",
 			       np->dev_name);
+			err = -EINVAL;
 			goto put;
 #endif
 		}
