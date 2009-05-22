From: Chaitanya Lala <clala@riverbed.com>
Subject: [net-next-2.6 PATCH 1/1] e1000e: Expose MDI-X status via ethtool
	change
Date: Fri, 22 May 2009 07:55:44 -0700
Message-ID: <20090522145544.GA8508@clala-laptop>
References: <F169D4F5E1F1974DBFAFABF47F60C10A33527C9D@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([206.169.144.7]:62280 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757804AbZEVOzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 10:55:09 -0400
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A33527C9D@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethtool is a standard way of getting information about ethernet
interfaces. We enhance ethtool kernel interface & e1000e to make
the MDI-X status readable via ethtool in userspace.

Signed-off-by: Chaitanya Lala <clala@riverbed.com>
Signed-off-by: Arthur Jones <ajones@riverbed.com>
---
 drivers/net/e1000e/ethtool.c |    8 ++++++++
 include/linux/ethtool.h      |    6 ++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 4d25ede..8bbade1 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -167,6 +167,14 @@ static int e1000_get_settings(struct net_device *netdev,
 
 	ecmd->autoneg = ((hw->phy.media_type == e1000_media_type_fiber) ||
 			 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	/* MDI-X => 2; MDI =>1; Invalid =>0 */
+	if ((hw->phy.media_type == e1000_media_type_copper) &&
+			!hw->mac.get_link_status)
+		ecmd->is_mdix = hw->phy.is_mdix ? MDI_X : MDI;
+	else
+		ecmd->is_mdix = MDI_INVALID;
+
 	return 0;
 }
 
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 380b042..0533d70 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -26,6 +26,7 @@ struct ethtool_cmd {
 	__u8	phy_address;
 	__u8	transceiver;	/* Which transceiver to use */
 	__u8	autoneg;	/* Enable or disable autonegotiation */
+	__u8	is_mdix;	/* MDI-X status tri-state value */
 	__u8	mdio_support;
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
@@ -632,6 +633,11 @@ struct ethtool_ops {
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
+/* Mode MDI or MDI-X */
+#define MDI_INVALID	0x00
+#define MDI		0x01
+#define MDI_X		0x02
+
 /* Wake-On-Lan options. */
 #define WAKE_PHY		(1 << 0)
 #define WAKE_UCAST		(1 << 1)
-- 
1.6.0.4

