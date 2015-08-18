From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 12/21] net: ipvlan: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:40 +0200
Message-ID: <1439886649-24166-13-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
 <1439886649-24166-7-git-send-email-phil@nwl.cc>
 <1439886649-24166-8-git-send-email-phil@nwl.cc>
 <1439886649-24166-9-git-send-email-phil@nwl.cc>
 <1439886649-24166-10-git-send-email-phil@nwl.cc>
 <1439886649-24166-11-git-send-email-phil@nwl.cc>
 <1439886649-24166-12-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Mahesh Bandewar <maheshb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:47642 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723AbbHRIaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:55 -0400
In-Reply-To: <1439886649-24166-12-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 20b58bd..a9268db 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -520,12 +520,11 @@ static void ipvlan_link_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
-	dev->priv_flags |= IFF_UNICAST_FLT;
+	dev->priv_flags |= IFF_UNICAST_FLT | IFF_NO_QUEUE;
 	dev->netdev_ops = &ipvlan_netdev_ops;
 	dev->destructor = free_netdev;
 	dev->header_ops = &ipvlan_header_ops;
 	dev->ethtool_ops = &ipvlan_ethtool_ops;
-	dev->tx_queue_len = 0;
 }
 
 static const struct nla_policy ipvlan_nl_policy[IFLA_IPVLAN_MAX + 1] =
-- 
2.1.2
