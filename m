From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] [IPV4]: Only panic if inetdev_init fails for loopback
Date: Tue, 05 Jun 2007 16:31:01 +1000
Message-ID: <E1HvSZJ-0003A3-00@gondolin.me.apana.org.au>
References: <20070605062929.GA12024@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4088 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756712AbXFEGbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 02:31:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4]: Only panic if inetdev_init fails for loopback

When I made the inetdev_init call work on all devices I incorrectly
left in the panic call as well.  It is obviously undesirable to
panic on an allocation failure for a normal network device.  This
patch moves the panic call under the loopback if clause.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/devinet.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1057,9 +1057,10 @@ static int inetdev_event(struct notifier
 	if (!in_dev) {
 		if (event == NETDEV_REGISTER) {
 			in_dev = inetdev_init(dev);
-			if (!in_dev)
-				panic("devinet: Failed to create loopback\n");
 			if (dev == &loopback_dev) {
+				if (!in_dev)
+					panic("devinet: "
+					      "Failed to create loopback\n");
 				in_dev->cnf.no_xfrm = 1;
 				in_dev->cnf.no_policy = 1;
 			}
