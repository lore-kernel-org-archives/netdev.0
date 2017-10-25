From: "Steven J. Hill" <steven.hill@cavium.com>
Subject: [PATCH v3] ethernet: cavium: octeon: Switch to using netdev_info().
Date: Wed, 25 Oct 2017 11:44:32 -0500
Message-ID: <1508949872-6599-1-git-send-email-steven.hill@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Steven J. Hill" <Steven.Hill@cavium.com>,
        David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0051.outbound.protection.outlook.com ([104.47.32.51]:4608
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751513AbdJYQv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 12:51:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steven J. Hill <Steven.Hill@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index 2887bca..3f6afb5 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -705,14 +705,15 @@ static int octeon_mgmt_ioctl_hwtstamp(struct net_device *netdev,
 			u64 clock_comp = (NSEC_PER_SEC << 32) /	octeon_get_io_clock_rate();
 			if (!ptp.s.ptp_en)
 				cvmx_write_csr(CVMX_MIO_PTP_CLOCK_COMP, clock_comp);
-			pr_info("PTP Clock: Using sclk reference at %lld Hz\n",
-				(NSEC_PER_SEC << 32) / clock_comp);
+			netdev_info(netdev,
+				    "PTP Clock using sclk reference @ %lldHz\n",
+				    (NSEC_PER_SEC << 32) / clock_comp);
 		} else {
 			/* The clock is already programmed to use a GPIO */
 			u64 clock_comp = cvmx_read_csr(CVMX_MIO_PTP_CLOCK_COMP);
-			pr_info("PTP Clock: Using GPIO %d at %lld Hz\n",
-				ptp.s.ext_clk_in,
-				(NSEC_PER_SEC << 32) / clock_comp);
+			netdev_info(netdev,
+				    "PTP Clock using GPIO%d @ %lld Hz\n",
+				    ptp.s.ext_clk_in, (NSEC_PER_SEC << 32) / clock_comp);
 		}
 
 		/* Enable the clock if it wasn't done already */
@@ -926,14 +927,11 @@ static void octeon_mgmt_adjust_link(struct net_device *netdev)
 	spin_unlock_irqrestore(&p->lock, flags);
 
 	if (link_changed != 0) {
-		if (link_changed > 0) {
-			pr_info("%s: Link is up - %d/%s\n", netdev->name,
-				phydev->speed,
-				phydev->duplex == DUPLEX_FULL ?
-				"Full" : "Half");
-		} else {
-			pr_info("%s: Link is down\n", netdev->name);
-		}
+		if (link_changed > 0)
+			netdev_info(netdev, "Link is up - %d/%s\n",
+				    phydev->speed, phydev->duplex == DUPLEX_FULL ? "Full" : "Half");
+		else
+			netdev_info(netdev, "Link is down\n");
 	}
 }
 
-- 
2.1.4
