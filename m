From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 19/26] netx-eth: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:53 +0400
Message-ID: <1239835980-22502-19-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-10-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-11-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-12-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-13-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-14-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-15-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-16-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-17-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-18-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:38634 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756546AbZDOWx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:27 -0400
Received: by mail-bw0-f169.google.com with SMTP id 17so114630bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:26 -0700 (PDT)
In-Reply-To: <1239835980-22502-18-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/netx-eth.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 1861d5b..946366d 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -301,6 +301,17 @@ netx_eth_phy_write(struct net_device *ndev, int phy_id, int reg, int value)
 	while (readl(NETX_MIIMU) & MIIMU_SNRDY);
 }
 
+static const struct net_device_ops netx_eth_netdev_ops = {
+	.ndo_open		= netx_eth_open,
+	.ndo_stop		= netx_eth_close,
+	.ndo_start_xmit		= netx_eth_hard_start_xmit,
+	.ndo_tx_timeout		= netx_eth_timeout,
+	.ndo_set_multicast_list	= netx_eth_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int netx_eth_enable(struct net_device *ndev)
 {
 	struct netx_eth_priv *priv = netdev_priv(ndev);
@@ -309,12 +320,8 @@ static int netx_eth_enable(struct net_device *ndev)
 
 	ether_setup(ndev);
 
-	ndev->open = netx_eth_open;
-	ndev->stop = netx_eth_close;
-	ndev->hard_start_xmit = netx_eth_hard_start_xmit;
-	ndev->tx_timeout = netx_eth_timeout;
+	ndev->netdev_ops = &netx_eth_netdev_ops;
 	ndev->watchdog_timeo = msecs_to_jiffies(5000);
-	ndev->set_multicast_list = netx_eth_set_multicast_list;
 
 	priv->msg_enable       = NETIF_MSG_LINK;
 	priv->mii.phy_id_mask  = 0x1f;
-- 
1.6.2.3

