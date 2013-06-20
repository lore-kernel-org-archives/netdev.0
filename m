From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 1/2] netdev: octeon_mgmt: Correct tx IFG workaround.
Date: Wed, 19 Jun 2013 17:40:19 -0700
Message-ID: <1371688820-4585-2-git-send-email-ddaney.cavm@gmail.com>
References: <1371688820-4585-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-mips@linux-mips.org, David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:44613 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935382Ab3FTAkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 20:40:31 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf11so5656792pab.24
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 17:40:31 -0700 (PDT)
In-Reply-To: <1371688820-4585-1-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

The previous fix was still too agressive to meet ieee specs.  Increase
to (14, 10).

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index e6e0292..1ef4148 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1141,10 +1141,13 @@ static int octeon_mgmt_open(struct net_device *netdev)
 		/* For compensation state to lock. */
 		ndelay(1040 * NS_PER_PHY_CLK);
 
-		/* Some Ethernet switches cannot handle standard
-		 * Interframe Gap, increase to 16 bytes.
+		/* Default Interframe Gaps are too small.  Recommended
+		 * workaround is.
+		 *
+		 * AGL_GMX_TX_IFG[IFG1]=14
+		 * AGL_GMX_TX_IFG[IFG2]=10
 		 */
-		cvmx_write_csr(CVMX_AGL_GMX_TX_IFG, 0x88);
+		cvmx_write_csr(CVMX_AGL_GMX_TX_IFG, 0xae);
 	}
 
 	octeon_mgmt_rx_fill_ring(netdev);
-- 
1.7.11.7
