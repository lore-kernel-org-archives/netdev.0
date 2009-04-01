From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/9] ixgbe: Fix ethtool output with advertised mode.
Date: Wed, 01 Apr 2009 00:33:02 -0700
Message-ID: <20090401073302.3749.35697.stgit@lost.foo-projects.org>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:58941
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759196AbZDAHd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:33:27 -0400
In-Reply-To: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Ethtool tries to get advertised speed from phy.autoneg_advertised.
However for copper media this wasn't happening until later do to
an other fix which moved mac.ops.setup_link_speed placement in
ixgbe_link_config(). This patch will display the default advertised
speeds if it can't yet get this information from phy.autoneg_advertised.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 18ecba7..34b4a84 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -129,6 +129,15 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		/*
+		 * It's possible that phy.autoneg_advertised may not be
+		 * set yet.  If so display what the default would be -
+		 * both 1G and 10G supported.
+		 */
+		if (!(ecmd->advertising & (ADVERTISED_1000baseT_Full |
+					   ADVERTISED_10000baseT_Full)))
+			ecmd->advertising |= (ADVERTISED_10000baseT_Full |
+					      ADVERTISED_1000baseT_Full);
 
 		ecmd->port = PORT_TP;
 	} else if (hw->phy.media_type == ixgbe_media_type_backplane) {

