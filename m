From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 13/14] e1000: 3 new driver stats for managability testing
Date: Fri, 15 Dec 2006 10:41:41 +0100
Message-ID: <1166175701.3365.135.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751501AbWLOKBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:01:07 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9h5B5006197
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:43:05 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9h4pm006196
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:43:04 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: 3 new driver stats for managability testing
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Add 3 extra packet redirect counters for tracking purposes to make sure we
can test that all packets arrive properly.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    3 +++
 drivers/net/e1000/e1000_main.c    |    7 +++++++
 2 files changed, 10 insertions(+)

Index: linux-2.6/drivers/net/e1000/e1000_ethtool.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_ethtool.c
+++ linux-2.6/drivers/net/e1000/e1000_ethtool.c
@@ -100,6 +100,9 @@ static const struct e1000_stats e1000_gs
 	{ "rx_csum_offload_errors", E1000_STAT(hw_csum_err) },
 	{ "rx_header_split", E1000_STAT(rx_hdr_split) },
 	{ "alloc_rx_buff_failed", E1000_STAT(alloc_rx_buff_failed) },
+	{ "tx_smbus", E1000_STAT(stats.mgptc) },
+	{ "rx_smbus", E1000_STAT(stats.mgprc) },
+	{ "dropped_smbus", E1000_STAT(stats.mgpdc) },
 };
 
 #define E1000_QUEUE_STATS_LEN 0
Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -3633,6 +3633,13 @@ e1000_update_stats(struct e1000_adapter 
 			adapter->phy_stats.receive_errors += phy_tmp;
 	}
 
+	/* Management Stats */
+	if (adapter->hw.mac_type > e1000_82544) {
+		adapter->stats.mgptc += E1000_READ_REG(hw, MGTPTC);
+		adapter->stats.mgprc += E1000_READ_REG(hw, MGTPRC);
+		adapter->stats.mgpdc += E1000_READ_REG(hw, MGTPDC);
+	}
+
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 #ifdef CONFIG_PCI_MSI

