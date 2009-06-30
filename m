From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/4] ixgbe: Fix device capabilities of 82599 single
	speed fiber NICs.
Date: Tue, 30 Jun 2009 14:44:16 -0700
Message-ID: <20090630214416.17464.72434.stgit@localhost.localdomain>
References: <20090630214349.17464.25370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:46658 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752859AbZF3Voc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 17:44:32 -0400
In-Reply-To: <20090630214349.17464.25370.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

82599 single speed fiber modules only support 10G/Full. Return
proper device capabilities while querrying the adapter and error
while changing device advertisement/speed/duplex capabilities.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 86f4f3e..0f7b6a3 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -139,7 +139,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	ecmd->autoneg = AUTONEG_ENABLE;
 	ecmd->transceiver = XCVR_EXTERNAL;
 	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
-	    (hw->mac.type == ixgbe_mac_82599EB)) {
+	    (hw->phy.multispeed_fiber)) {
 		ecmd->supported |= (SUPPORTED_1000baseT_Full |
 		                    SUPPORTED_Autoneg);
 
@@ -217,7 +217,7 @@ static int ixgbe_set_settings(struct net_device *netdev,
 	s32 err = 0;
 
 	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
-	    (hw->mac.type == ixgbe_mac_82599EB)) {
+	    (hw->phy.multispeed_fiber)) {
 		/* 10000/copper and 1000/copper must autoneg
 		 * this function does not support any duplex forcing, but can
 		 * limit the advertising of the adapter to only 10000 or 1000 */
@@ -245,6 +245,7 @@ static int ixgbe_set_settings(struct net_device *netdev,
 	} else {
 		/* in this case we currently only support 10Gb/FULL */
 		if ((ecmd->autoneg == AUTONEG_ENABLE) ||
+		    (ecmd->advertising != ADVERTISED_10000baseT_Full) ||
 		    (ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
 			return -EINVAL;
 	}

