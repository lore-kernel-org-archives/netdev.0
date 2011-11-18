From: Olaf Hering <olaf@aepfle.de>
Subject: [PATCH] xen-netfront: report link speed to ethtool
Date: Fri, 18 Nov 2011 17:48:05 +0100
Message-ID: <20111118164805.GA14345@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:14136 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754718Ab1KRQsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 11:48:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add .get_settings function, return fake data so that ethtool can get
enough information. For some application like VCS, this is useful,
otherwise some of application logic will get panic.
The reported data refers to VMWare vmxnet.

Signed-off-by: Xin Wei Hu <xwhu@suse.com>
Signed-off-by: Chunyan Liu <cyliu@suse.com>
Signed-off-by: Olaf Hering <olaf@aepfle.de>

---
 drivers/net/xen-netfront.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

Index: linux-3.2-rc2/drivers/net/xen-netfront.c
===================================================================
--- linux-3.2-rc2.orig/drivers/net/xen-netfront.c
+++ linux-3.2-rc2/drivers/net/xen-netfront.c
@@ -1727,6 +1727,17 @@ static void netback_changed(struct xenbu
 	}
 }
 
+static int xennet_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	ecmd->supported = SUPPORTED_1000baseT_Full | SUPPORTED_TP;
+	ecmd->advertising = ADVERTISED_TP;
+	ecmd->port = PORT_TP;
+	ecmd->transceiver = XCVR_INTERNAL;
+	ecmd->speed = SPEED_1000;
+	ecmd->duplex = DUPLEX_FULL;
+	return 0;
+}
+
 static const struct xennet_stat {
 	char name[ETH_GSTRING_LEN];
 	u16 offset;
@@ -1774,6 +1785,7 @@ static const struct ethtool_ops xennet_e
 {
 	.get_link = ethtool_op_get_link,
 
+	.get_settings = xennet_get_settings,
 	.get_sset_count = xennet_get_sset_count,
 	.get_ethtool_stats = xennet_get_ethtool_stats,
 	.get_strings = xennet_get_strings,
