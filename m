From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Subject: [RESEND] ll_temac: Add support for phy_mii_ioctl
Date: Tue,  8 Nov 2011 10:47:45 +0100
Message-ID: <1320745665-11688-1-git-send-email-ricardo.ribalda@gmail.com>
Cc: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
To: davem@davemloft.net, ian.campbell@citrix.com,
	eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63467 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab1KHJrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 04:47:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the ioctl support for the driver. So userspace
programs like mii-tool can work.

Resend in merge window

Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 4d1658e..b26e5ee 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -915,12 +915,26 @@ temac_poll_controller(struct net_device *ndev)
 }
 #endif
 
+static int temac_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+
+	if (!netif_running(ndev))
+		return -EINVAL;
+
+	if (!lp->phy_dev)
+		return -EINVAL;
+
+	return phy_mii_ioctl(lp->phy_dev, rq, cmd);
+}
+
 static const struct net_device_ops temac_netdev_ops = {
 	.ndo_open = temac_open,
 	.ndo_stop = temac_stop,
 	.ndo_start_xmit = temac_start_xmit,
 	.ndo_set_mac_address = netdev_set_mac_address,
 	.ndo_validate_addr = eth_validate_addr,
+	.ndo_do_ioctl = temac_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = temac_poll_controller,
 #endif
-- 
1.7.7.1
