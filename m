From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] net: don't clear IFF_XMIT_DST_RELEASE in ether_setup
Date: Wed, 14 Sep 2011 09:05:02 -0400
Message-ID: <1316005502-7341-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33269 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932406Ab1INNLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 09:11:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

d88733150 introduced the IFF_SKB_TX_SHARING flag, which I unilaterally set in
ether_setup.  In doing this I didn't realize that other flags (such as
IFF_XMIT_DST_RELEASE) might be set prior to calling the ether_setup routine.
This patch changes ether_setup to or in SKB_TX_SHARING so as not to
inadvertently clear other existing flags.  Thanks to Pekka Riikonen for pointing
out my error

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Pekka Riikonen <priikone@iki.fi>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/ethernet/eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 27997d3..a246836 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -340,7 +340,7 @@ void ether_setup(struct net_device *dev)
 	dev->addr_len		= ETH_ALEN;
 	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
-	dev->priv_flags		= IFF_TX_SKB_SHARING;
+	dev->priv_flags		|= IFF_TX_SKB_SHARING;
 
 	memset(dev->broadcast, 0xFF, ETH_ALEN);
 
-- 
1.7.6
