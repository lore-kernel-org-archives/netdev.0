From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to drvinfo
	and return it
Date: Fri, 26 Feb 2010 03:54:20 -0800
Message-ID: <20100226115355.20213.59254.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:34103 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935157Ab0BZLyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 06:54:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The drvinfo struct should include the number of strings that
get_rx_ntuple will return.  It will be variable if an underlying
driver implements its own get_rx_ntuple routine, so userspace
needs to know how much data is coming.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/ethtool.h |    1 +
 net/core/ethtool.c      |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index cca1c3d..f7992a2 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -63,6 +63,7 @@ struct ethtool_drvinfo {
 	char	reserved2[12];
 	__u32	n_priv_flags;	/* number of flags valid in ETHTOOL_GPFLAGS */
 	__u32	n_stats;	/* number of u64's from ETHTOOL_GSTATS */
+	__u32	n_ntuples;	/* number of n-tuple filters from GSTRINGS */
 	__u32	testinfo_len;
 	__u32	eedump_len;	/* Size of data from ETHTOOL_GEEPROM (bytes) */
 	__u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes) */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 31b1edd..1c94f48 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -224,6 +224,9 @@ static noinline int ethtool_get_drvinfo(struct net_device *dev, void __user *use
 		rc = ops->get_sset_count(dev, ETH_SS_PRIV_FLAGS);
 		if (rc >= 0)
 			info.n_priv_flags = rc;
+		rc = ops->get_sset_count(dev, ETH_SS_NTUPLE_FILTERS);
+		if (rc >= 0)
+			info.n_ntuples = rc;
 	}
 	if (ops->get_regs_len)
 		info.regdump_len = ops->get_regs_len(dev);

