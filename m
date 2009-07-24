From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 08/13] igb: remove unused switch statement from
	igb_set_wol
Date: Thu, 23 Jul 2009 21:09:30 -0700
Message-ID: <20090724040929.30709.31896.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:33961 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751689AbZGXEJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:09:46 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There is a switch statement in igb_set_wol that defaults to break and
doesn't actually do anything.  As such it should be removed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index a9c37cb..df2d234 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1836,7 +1836,6 @@ static void igb_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 static int igb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
 
 	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
 		return -EOPNOTSUPP;
@@ -1845,11 +1844,6 @@ static int igb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	    !device_can_wakeup(&adapter->pdev->dev))
 		return wol->wolopts ? -EOPNOTSUPP : 0;
 
-	switch (hw->device_id) {
-	default:
-		break;
-	}
-
 	/* these settings will always override what we currently have */
 	adapter->wol = 0;
 

