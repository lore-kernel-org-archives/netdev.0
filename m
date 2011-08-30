From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 2/2] dummy: implement carrier change
Date: Tue, 30 Aug 2011 16:46:48 +0200
Message-ID: <1314715608-978-3-git-send-email-jpirko@redhat.com>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754153Ab1H3Oq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:46:59 -0400
In-Reply-To: <1314715608-978-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/dummy.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index a7c5e88..1e32e14 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -112,6 +112,15 @@ static void dummy_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+static int dummy_change_carrier(struct net_device *dev, bool new_carrier)
+{
+	if (new_carrier)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
+	return 0;
+}
+
 static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_init		= dummy_dev_init,
 	.ndo_start_xmit		= dummy_xmit,
@@ -119,6 +128,7 @@ static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_set_rx_mode	= set_multicast_list,
 	.ndo_set_mac_address	= dummy_set_address,
 	.ndo_get_stats64	= dummy_get_stats64,
+	.ndo_change_carrier	= dummy_change_carrier,
 };
 
 static void dummy_setup(struct net_device *dev)
-- 
1.7.6
