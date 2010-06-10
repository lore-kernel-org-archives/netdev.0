From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/7] netpoll: Set npinfo to NULL even with ndo_netpoll_cleanup
Date: Thu, 10 Jun 2010 22:42:00 +1000
Message-ID: <E1OMh56-0004N0-Oy@gondolin.me.apana.org.au>
References: <20100610124047.GA16658@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen He
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52016 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758758Ab0FJMmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 08:42:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netpoll: Set npinfo to NULL even with ndo_netpoll_cleanup

Sinec we have to null npinfo regardless of whether there is a
ndo_netpoll_cleanup, it makes sense to do this unconditionally
in netpoll_cleanup rather than having every driver do it by
themselves.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/core/netpoll.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 94825b1..748c930 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -898,8 +898,7 @@ void netpoll_cleanup(struct netpoll *np)
 				ops = np->dev->netdev_ops;
 				if (ops->ndo_netpoll_cleanup)
 					ops->ndo_netpoll_cleanup(np->dev);
-				else
-					np->dev->npinfo = NULL;
+				np->dev->npinfo = NULL;
 			}
 		}
 
