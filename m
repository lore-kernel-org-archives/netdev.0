From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC net-next PATCH 3/4] ethtool: Add new set commands
Date: Wed, 27 Jul 2011 15:17:59 -0700
Message-ID: <20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29027 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304Ab1G0WSD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 18:18:03 -0400
In-Reply-To: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new set commands to configure the number of SR-IOV VFs, the
number of VM queues and spoof checking on/off switch.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/ethtool.h |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c6e427a..c4972ba 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -36,12 +36,14 @@ struct ethtool_cmd {
 	__u8	mdio_support;
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
+	__u32	num_vfs;	/* Enable SR-IOV VFs */
+	__u32	num_vmqs;	/* Set number of queues for VMDq */
 	__u16	speed_hi;       /* The forced speed (upper
 				 * bits) in Mbps. Please use
 				 * ethtool_cmd_speed()/_set() to
 				 * access it */
 	__u8	eth_tp_mdix;
-	__u8	reserved2;
+	__u8	spoof_check;	/* Enable/Disable anti-spoofing */
 	__u32	lp_advertising;	/* Features the link partner advertises */
 	__u32	reserved[2];
 };
@@ -1121,6 +1123,13 @@ struct ethtool_ops {
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
+/* Enable or disable MAC and/or VLAN spoofchecking.If this is
+ * set to enable, then depending on the controller capabilities
+ * MAC and/or VLAN spoofing will be turned on.
+ */
+#define SPOOFCHECK_DISABLE     0x00
+#define SPOOFCHECK_ENABLE      0x01
+
 /* Mode MDI or MDI-X */
 #define ETH_TP_MDI_INVALID	0x00
 #define ETH_TP_MDI		0x01

