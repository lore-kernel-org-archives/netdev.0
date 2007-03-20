From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: Fix ingress locking
Date: Tue, 20 Mar 2007 18:15:03 +0100
Message-ID: <46001697.30409@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040906090908090202040804"
Cc: Linux Netdev List <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54683 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965544AbXCTRPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 13:15:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040906090908090202040804
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------040906090908090202040804
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NET_SCHED]: Fix ingress locking

Ingress queueing uses a seperate lock for serializing enqueue operations,
but fails to properly protect itself against concurrent changes to the
qdisc tree. Use queue_lock for now since the real fix it quite intrusive.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 11985909b582dc688b5a7c0f73f16244224116f4
tree 0ee26bec34053f6c9b5f905ffbc1437881428eeb
parent f1b9a0694552e18e7a43c292d21abe3b51dfcae2
author Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 16:11:56 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 16:11:56 +0100

 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index cf71614..5984b55 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1750,10 +1750,10 @@ static int ing_filter(struct sk_buff *sk
 
 		skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_INGRESS);
 
-		spin_lock(&dev->ingress_lock);
+		spin_lock(&dev->queue_lock);
 		if ((q = dev->qdisc_ingress) != NULL)
 			result = q->enqueue(skb, q);
-		spin_unlock(&dev->ingress_lock);
+		spin_unlock(&dev->queue_lock);
 
 	}
 

--------------040906090908090202040804--
