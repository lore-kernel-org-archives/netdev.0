From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 20/28] mlxsw: spectrum: Add set_rx_mode ndo stub
Date: Wed,  2 Dec 2015 21:07:43 +0100
Message-ID: <1449086871-19911-21-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33740 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755397AbbLBUIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:20 -0500
Received: by wmec201 with SMTP id c201so270761662wme.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:19 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add just a stub for now. This allows to pass check in dev_ifsioc,
SIOCADDMULTI and SIOCDELMULTI cases. Teamd is using these to add LACP
slow MAC.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 14a9a9f..a397cc1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -417,6 +417,10 @@ static netdev_tx_t mlxsw_sp_port_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static void mlxsw_sp_set_rx_mode(struct net_device *dev)
+{
+}
+
 static int mlxsw_sp_port_set_mac_address(struct net_device *dev, void *p)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
@@ -725,6 +729,7 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_open		= mlxsw_sp_port_open,
 	.ndo_stop		= mlxsw_sp_port_stop,
 	.ndo_start_xmit		= mlxsw_sp_port_xmit,
+	.ndo_set_rx_mode	= mlxsw_sp_set_rx_mode,
 	.ndo_set_mac_address	= mlxsw_sp_port_set_mac_address,
 	.ndo_change_mtu		= mlxsw_sp_port_change_mtu,
 	.ndo_get_stats64	= mlxsw_sp_port_get_stats64,
-- 
1.9.3
