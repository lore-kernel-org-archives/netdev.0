From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: dummy: add more features
Date: Mon, 19 Oct 2015 20:17:59 -0700
Message-ID: <1445311079.30896.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33781 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbbJTDSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 23:18:01 -0400
Received: by pabrc13 with SMTP id rc13so6449037pab.0
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 20:18:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While testing my SIT/GRO patch using netfilter TEE module and a dummy
device, I found some features were missing :

TSO IPv6, UFO, and encapsulated traffic.

ethtool -k dummy0 now gives :
...
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: on
	tx-tcp6-segmentation: on
udp-fragmentation-offload: on
...
tx-gre-segmentation: on
tx-ipip-segmentation: on
tx-sit-segmentation: on
tx-udp_tnl-segmentation: on

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/dummy.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 815eb94990f5..69fc8409a973 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -147,8 +147,12 @@ static void dummy_setup(struct net_device *dev)
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
-	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
+	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST;
+	dev->features	|= NETIF_F_ALL_TSO | NETIF_F_UFO;
 	dev->features	|= NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
+	dev->features	|= NETIF_F_GSO_ENCAP_ALL;
+	dev->hw_features |= dev->features;
+	dev->hw_enc_features |= dev->features;
 	eth_hw_addr_random(dev);
 }
 
