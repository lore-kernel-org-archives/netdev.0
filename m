From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6] netxen: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 18:15:34 +0530
Message-ID: <20091007124525.GA30122@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:65494 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759103AbZJGMqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 08:46:22 -0400
Received: by fxm27 with SMTP id 27so4553047fxm.17
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 05:45:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the private adapter structure.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/netxen/netxen_nic.h      |    2 --
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 7384f59..5c766b5 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1203,8 +1203,6 @@ struct netxen_adapter {
 
 	struct work_struct  tx_timeout_task;
 
-	struct net_device_stats net_stats;
-
 	nx_nic_intr_coalesce_t coal;
 
 	unsigned long state;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b5aa974..0039b85 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1923,7 +1923,7 @@ request_reset:
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct net_device_stats *stats = &adapter->net_stats;
+	struct net_device_stats *stats = &netdev->stats;
 
 	memset(stats, 0, sizeof(*stats));
 
-- 
1.6.0.4

