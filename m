From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] e1000e: Expose MDI-X status via ethtool change
Date: Mon, 08 Jun 2009 17:28:54 -0700
Message-ID: <20090609002854.4909.69332.stgit@localhost.localdomain>
References: <20090609002817.4909.44004.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Chaitanya Lala <clala@riverbed.com>,
	Arthur Jones <ajones@riverbed.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:43959 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753832AbZFIA3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 20:29:12 -0400
In-Reply-To: <20090609002817.4909.44004.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chaitanya Lala <clala@riverbed.com>

Ethtool is a standard way of getting information about
ethernet interfaces.  We enhance ethtool kernel interface
& e1000e to make the MDI-X status readable via ethtool in
userspace.

Signed-off-by: Chaitanya Lala <clala@riverbed.com>
Signed-off-by: Arthur Jones <ajones@riverbed.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |    9 +++++++++
 include/linux/ethtool.h      |    8 +++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 3d64356..1bf4d2a 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -167,6 +167,15 @@ static int e1000_get_settings(struct net_device *netdev,
 
 	ecmd->autoneg = ((hw->phy.media_type == e1000_media_type_fiber) ||
 			 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	/* MDI-X => 2; MDI =>1; Invalid =>0 */
+	if ((hw->phy.media_type == e1000_media_type_copper) &&
+	    !hw->mac.get_link_status)
+		ecmd->eth_tp_mdix = hw->phy.is_mdix ? ETH_TP_MDI_X :
+		                                      ETH_TP_MDI;
+	else
+		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+
 	return 0;
 }
 
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 380b042..9b660bd 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -30,7 +30,8 @@ struct ethtool_cmd {
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;
-	__u16	reserved2;
+	__u8	eth_tp_mdix;
+	__u8	reserved2;
 	__u32	lp_advertising;	/* Features the link partner advertises */
 	__u32	reserved[2];
 };
@@ -632,6 +633,11 @@ struct ethtool_ops {
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
+/* Mode MDI or MDI-X */
+#define ETH_TP_MDI_INVALID	0x00
+#define ETH_TP_MDI		0x01
+#define ETH_TP_MDI_X		0x02
+
 /* Wake-On-Lan options. */
 #define WAKE_PHY		(1 << 0)
 #define WAKE_UCAST		(1 << 1)

