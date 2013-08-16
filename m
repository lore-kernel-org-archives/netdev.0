From: Neel Patel <neepatel@cisco.com>
Subject: [PATCH v3 3/3] drivers/net: enic: Generate notification of hardware crash
Date: Fri, 16 Aug 2013 15:47:41 -0700
Message-ID: <1376693261-1949-4-git-send-email-neepatel@cisco.com>
References: <1376693261-1949-1-git-send-email-neepatel@cisco.com>
Cc: umalhi@cisco.com, Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>,
	Christian Benvenuti <benve@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:39998 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757854Ab3HPWrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:47:47 -0400
In-Reply-To: <1376693261-1949-1-git-send-email-neepatel@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch generates a hardware crash notification (NETDEV_REBOOT)
during reset. After a hardware crash, ENIC resets all its resources
including queue pair filters programmed by USNIC. USNIC registers for
this notification, and on receiving it, reprograms the queue pair
filters.

Signed-off-by: Neel Patel <neepatel@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      | 2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index cacca29..be16731 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.39"
+#define DRV_VERSION		"2.1.1.43"
 #define DRV_COPYRIGHT		"Copyright 2008-2013 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 7f8891b..bcf15b1 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1743,6 +1743,7 @@ static void enic_reset(struct work_struct *work)
 	enic_dev_set_ig_vlan_rewrite_mode(enic);
 	enic_open(enic->netdev);
 	spin_unlock(&enic->enic_api_lock);
+	call_netdevice_notifiers(NETDEV_REBOOT, enic->netdev);
 
 	rtnl_unlock();
 }
-- 
1.8.4-rc0
