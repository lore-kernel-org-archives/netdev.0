From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 3/4] e1000: only enable TSO6 via ethtool when using correct hardware
Date: Thu, 19 Jun 2008 17:19:02 -0400
Message-ID: <20080619211902.GE22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36287 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754195AbYFSVTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 17:19:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When enabling TSO via ethool on e1000, it is possible to set
NETIF_F_TSO6 on hardware that does not support it.  Setting TSO via
ethtool now matches the settings used when the hardware is probed.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/e1000/e1000_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 701531e..a3f6a9c 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -347,7 +347,7 @@ e1000_set_tso(struct net_device *netdev, u32 data)
 	else
 		netdev->features &= ~NETIF_F_TSO;
 
-	if (data)
+	if (data && (adapter->hw.mac_type > e1000_82547_rev_2))
 		netdev->features |= NETIF_F_TSO6;
 	else
 		netdev->features &= ~NETIF_F_TSO6;
-- 
1.5.2.1

