From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] ethtool: Add PHY type to ethtool get_drvinfo
Date: Tue, 17 Nov 2009 08:13:24 -0800
Message-ID: <20091117161309.11341.9165.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:42438 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752608AbZKQQN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 11:13:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Allow the PHY type to be passed from a driver to ethtool when
ethtool -i ethX is called.  With newer network cards having SFP
and SFP+ PHY cages, this information can be useful, especially
if the NIC supports hot-swapping of the PHY modules.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/ethtool.h |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index edd03b7..d6606a5 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -59,7 +59,8 @@ struct ethtool_drvinfo {
 	char	bus_info[ETHTOOL_BUSINFO_LEN];	/* Bus info for this IF. */
 				/* For PCI devices, use pci_name(pci_dev). */
 	char	reserved1[32];
-	char	reserved2[12];
+	char	reserved2[11];
+	__u8	phy_type;	/* PHY type present on the NIC */
 	__u32	n_priv_flags;	/* number of flags valid in ETHTOOL_GPFLAGS */
 	__u32	n_stats;	/* number of u64's from ETHTOOL_GSTATS */
 	__u32	testinfo_len;
@@ -291,6 +292,27 @@ enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 };
 
+/*
+ * PHY types supported
+ *
+ * 0    - PHY not specified
+ * 1    - SFP/SFP+ Fiber (SR and LR)
+ * 2    - XFP Fiber (SR and LR)
+ * 3    - SFP+ Direct Attach (TwinAX)
+ * 4    - BASE-T (RJ-45)
+ * MAX  - PHY not present
+ */
+enum ethtool_phy_type {
+	ETH_PHY_UNSPECIFIED = 0,
+	ETH_PHY_SFP_FIBER,
+	ETH_PHY_XFP_FIBER,
+	ETH_PHY_DA_TWINAX,
+	ETH_PHY_BASE_T,
+
+	/* This must be the last entry */
+	ETH_PHY_NOT_PRESENT,
+};
+
 /* The following structures are for supporting RX network flow
  * classification configuration. Note, all multibyte fields, e.g.,
  * ip4src, ip4dst, psrc, pdst, spi, etc. are expected to be in network

