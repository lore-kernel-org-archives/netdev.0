From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [net-next PATCH] via-velocity: Enable scatter/gather IO by default
Date: Thu, 11 Feb 2010 16:39:55 +0100
Message-ID: <20100211163955.1b1dbe2c@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:30027 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754928Ab0BKPkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 10:40:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduces CPU utilization significantly with sendfile for example.

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
Also good to have if Krishnas tcp_sendmsg optimizations,

  http://patchwork.ozlabs.org/patch/42944/

get merged.

 drivers/net/via-velocity.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 317aa34..18770ac 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2825,7 +2825,7 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT);
 
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
-		NETIF_F_HW_VLAN_RX | NETIF_F_IP_CSUM;
+		NETIF_F_HW_VLAN_RX | NETIF_F_IP_CSUM | NETIF_F_SG;
 
 	ret = register_netdev(dev);
 	if (ret < 0)
-- 
1.6.0.4

