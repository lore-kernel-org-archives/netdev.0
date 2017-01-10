From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/3] sfc: implement ndo_get_phys_port_name
Date: Tue, 10 Jan 2017 16:23:56 +0000
Message-ID: <c7406bdc-f223-acd8-325e-16e2d2793f90@solarflare.com>
References: <78b911fa-ba82-093e-ba00-f4bdb09f1896@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:31149 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758105AbdAJQYO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 11:24:14 -0500
In-Reply-To: <78b911fa-ba82-093e-ba00-f4bdb09f1896@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

Output is of the form p<port-number>.
Note that the port numbers don't necessarily map one-to-one to physical
 cages, partly because of 4x10G port modes on QSFP+ and partly because
 of hw/fw implementation details.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index c1aefbd9..bdbacb2 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2347,6 +2347,16 @@ int efx_get_phys_port_id(struct net_device *net_dev,
 		return -EOPNOTSUPP;
 }
 
+static int efx_get_phys_port_name(struct net_device *net_dev,
+				  char *name, size_t len)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	if (snprintf(name, len, "p%u", efx->port_num) >= len)
+		return -EINVAL;
+	return 0;
+}
+
 static int efx_vlan_rx_add_vid(struct net_device *net_dev, __be16 proto, u16 vid)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
@@ -2389,6 +2399,7 @@ static const struct net_device_ops efx_netdev_ops = {
 	.ndo_set_vf_link_state  = efx_sriov_set_vf_link_state,
 #endif
 	.ndo_get_phys_port_id   = efx_get_phys_port_id,
+	.ndo_get_phys_port_name	= efx_get_phys_port_name,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = efx_netpoll,
 #endif
