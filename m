From: Sergey Matyukevich <geomatsi@gmail.com>
Subject: [PATCH 1/2] [PATCH] ucc_geth driver: add ioctl
Date: Mon,  7 Jun 2010 22:38:13 +0400
Message-ID: <1275935894-30483-1-git-send-email-geomatsi@gmail.com>
Cc: Li Yang <leoli@freescale.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Sergey Matyukevich <geomatsi@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:44473 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894Ab0FGSmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 14:42:45 -0400
Received: by ewy23 with SMTP id 23so45175ewy.1
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 11:42:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ioctl operation (ndo_do_ioctl) is added to make mii-tools work

Signed-off-by: Sergey Matyukevich <geomatsi@gmail.com>
---
 drivers/net/ucc_geth.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 4a34833..538148a 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3702,6 +3702,19 @@ static phy_interface_t to_phy_interface(const char *phy_connection_type)
 	return PHY_INTERFACE_MODE_MII;
 }
 
+static int ucc_geth_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	if (!ugeth->phydev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(ugeth->phydev, if_mii(rq), cmd);
+}
+
 static const struct net_device_ops ucc_geth_netdev_ops = {
 	.ndo_open		= ucc_geth_open,
 	.ndo_stop		= ucc_geth_close,
@@ -3711,6 +3724,7 @@ static const struct net_device_ops ucc_geth_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_multicast_list	= ucc_geth_set_multi,
 	.ndo_tx_timeout		= ucc_geth_timeout,
+	.ndo_do_ioctl		= ucc_geth_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ucc_netpoll,
 #endif
-- 
1.6.2.5

