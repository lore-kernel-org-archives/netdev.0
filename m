From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: disallow enabling firmware debug from a VF
Date: Thu, 8 Jun 2017 19:20:36 -0700
Message-ID: <20170609022036.GA1327@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0044.outbound.protection.outlook.com ([104.47.40.44]:37532
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751469AbdFICUq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 22:20:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Derek Chickles <derek.chickles@cavium.com>

Disallow enabling firmware debug from a VF.  Only PF is allowed to do that.

Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 9 ++++++++-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 4 ----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 579dc73..9a520a7 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -700,6 +700,13 @@ static void lio_set_msglevel(struct net_device *netdev, u32 msglvl)
 	lio->msg_enable = msglvl;
 }
 
+static void lio_vf_set_msglevel(struct net_device *netdev, u32 msglvl)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	lio->msg_enable = msglvl;
+}
+
 static void
 lio_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
 {
@@ -2611,7 +2618,7 @@ static const struct ethtool_ops lio_vf_ethtool_ops = {
 	.get_regs_len		= lio_get_regs_len,
 	.get_regs		= lio_get_regs,
 	.get_msglevel		= lio_get_msglevel,
-	.set_msglevel		= lio_set_msglevel,
+	.set_msglevel		= lio_vf_set_msglevel,
 	.get_sset_count		= lio_vf_get_sset_count,
 	.get_coalesce		= lio_get_intr_coalesce,
 	.set_coalesce		= lio_set_intr_coalesce,
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 31d737c..ad7ea6d 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -2997,10 +2997,6 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
 					     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
-		if ((debug != -1) && (debug & NETIF_MSG_HW))
-			liquidio_set_feature(netdev, OCTNET_CMD_VERBOSE_ENABLE,
-					     0);
-
 		if (setup_link_status_change_wq(netdev))
 			goto setup_nic_dev_fail;
 
