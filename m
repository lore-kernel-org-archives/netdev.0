From: Chaitanya Lala <clala@riverbed.com>
Subject: [PATCH net-next-2.6 1/1] e1000e: Expose MDI-X status via ethtool
	change
Date: Wed, 27 May 2009 16:15:42 -0700
Message-ID: <20090527231542.GA19664@clala-laptop>
References: <1243353768.3188.2.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([206.169.144.12]:39935 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756456AbZE0XO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 19:14:56 -0400
Content-Disposition: inline
In-Reply-To: <1243353768.3188.2.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethtool is a standard way of getting information about ethernet
interfaces. We enhance ethtool kernel interface & e1000e to make
the MDI-X status readable via ethtool in userspace.

Signed-off-by: Chaitanya Lala <clala@riverbed.com>
Signed-off-by: Arthur Jones <ajones@riverbed.com>
---
 drivers/net/e1000e/ethtool.c |    8 ++++++++
 include/linux/ethtool.h      |    8 +++++++-
 2 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 4d25ede..b6aea6b 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -167,6 +167,14 @@ static int e1000_get_settings(struct net_device *netdev,
 
 	ecmd->autoneg = ((hw->phy.media_type == e1000_media_type_fiber) ||
 			 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	/* MDI-X => 2; MDI =>1; Invalid =>0 */
+	if ((hw->phy.media_type == e1000_media_type_copper) &&
+		!hw->mac.get_link_status)
+		ecmd->is_mdix = hw->phy.is_mdix ? MDI_X : MDI;
+	else
+		ecmd->is_mdix = MDI_INVALID;
+
 	return 0;
 }
 
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 380b042..b553bdb 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -30,7 +30,8 @@ struct ethtool_cmd {
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;
-	__u16	reserved2;
+	__u8	is_mdix;
+	__u8	reserved2;
 	__u32	lp_advertising;	/* Features the link partner advertises */
 	__u32	reserved[2];
 };
@@ -632,6 +633,11 @@ struct ethtool_ops {
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
+/* Mode MDI or MDI-X */
+#define MDI_INVALID 0x00
+#define MDI         0x01
+#define MDI_X       0x02
+
 /* Wake-On-Lan options. */
 #define WAKE_PHY		(1 << 0)
 #define WAKE_UCAST		(1 << 1)
-- 
1.6.0.4

