From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 10/29] ixgbe: fix ethtool disable csum for
	ipv6
Date: Thu, 11 Sep 2008 19:57:17 -0700
Message-ID: <20080912025702.6234.26482.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:19852 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766AbYILC5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:57:30 -0400
Received: by wf-out-1314.google.com with SMTP id 27so621348wfd.4
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:57:30 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

ethtool was not disabling the correct netif flags when setting
checksum disable.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 64460b4..2506f9e 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -241,7 +241,7 @@ static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
 	if (data)
 		netdev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
 	else
-		netdev->features &= ~NETIF_F_IP_CSUM;
+		netdev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
 
 	return 0;
 }

