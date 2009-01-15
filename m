From: Phil Sutter <n0-1@freewrt.org>
Subject: [PATCH] korina: drop leftover assignment
Date: Thu, 15 Jan 2009 23:29:57 +0100
Message-ID: <20090115223008.B784E4043837@mail.nwl.cc>
References: <1232058598-15811-1-git-send-email-n0-1@freewrt.org>
 <1232058598-15811-2-git-send-email-n0-1@freewrt.org>
Cc: davem@davemloft.net, jeff@garzik.org, florian@openwrt.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:58494 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935578AbZAOWjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 17:39:43 -0500
In-Reply-To: <1232058598-15811-2-git-send-email-n0-1@freewrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the assigned value is being overwritten shortly after, it can be
dropped and so the whole variable definition moved to the start of the
function.

Signed-off-by: Phil Sutter <n0-1@freewrt.org>
---
 drivers/net/korina.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 60ae7bf..75010ca 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -743,6 +743,7 @@ static struct ethtool_ops netdev_ethtool_ops = {
 static void korina_alloc_ring(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
+	struct sk_buff *skb;
 	int i;
 
 	/* Initialize the transmit descriptors */
@@ -758,8 +759,6 @@ static void korina_alloc_ring(struct net_device *dev)
 
 	/* Initialize the receive descriptors */
 	for (i = 0; i < KORINA_NUM_RDS; i++) {
-		struct sk_buff *skb = lp->rx_skb[i];
-
 		skb = dev_alloc_skb(KORINA_RBSIZE + 2);
 		if (!skb)
 			break;
-- 
1.5.6.4

