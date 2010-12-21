From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH 2/2 -next] sundance: Program station address into HW
Date: Tue, 21 Dec 2010 12:02:26 +0000
Message-ID: <20101221120226.GA18412@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:49222 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045Ab0LUMC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 07:02:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Program adapter's StationAddress register when changing device MAC address

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/sundance.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index d82944c..826fe34 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -434,6 +434,7 @@ static void netdev_error(struct net_device *dev, int intr_status);
 static void netdev_error(struct net_device *dev, int intr_status);
 static void set_rx_mode(struct net_device *dev);
 static int __set_mac_addr(struct net_device *dev);
+static int sundance_set_mac_addr(struct net_device *dev, void *data);
 static struct net_device_stats *get_stats(struct net_device *dev);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int  netdev_close(struct net_device *dev);
@@ -467,7 +468,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_do_ioctl 		= netdev_ioctl,
 	.ndo_tx_timeout		= tx_timeout,
 	.ndo_change_mtu		= change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address 	= sundance_set_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -1595,6 +1596,19 @@ static int __set_mac_addr(struct net_device *dev)
 	return 0;
 }
 
+/* Invoked with rtnl_lock held */
+static int sundance_set_mac_addr(struct net_device *dev, void *data)
+{
+	const struct sockaddr *addr = data;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	__set_mac_addr(dev);
+
+	return 0;
+}
+
 static const struct {
 	const char name[ETH_GSTRING_LEN];
 } sundance_stats[] = {
-- 
1.7.2.2

