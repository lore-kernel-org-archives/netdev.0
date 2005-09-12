From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 1/3] 3c59x: bounds checking for hw_checksums
Date: Mon, 12 Sep 2005 10:48:52 -0400
Message-ID: <09122005104852.31525@bilbo.tuxdriver.com>
References: <09122005104852.31469@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751315AbVILO5m@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104852.31469@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add bounds checking to usage of hw_checksums module parameter array.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/3c59x.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1536,9 +1536,11 @@ static int __devinit vortex_probe1(struc
 		dev->hard_start_xmit = boomerang_start_xmit;
 		/* Actually, it still should work with iommu. */
 		dev->features |= NETIF_F_SG;
-		if (((hw_checksums[card_idx] == -1) && (vp->drv_flags & HAS_HWCKSM)) ||
-					(hw_checksums[card_idx] == 1)) {
-				dev->features |= NETIF_F_IP_CSUM;
+		if ((card_idx < MAX_UNITS) &&
+		    (((hw_checksums[card_idx] == -1) &&
+		      (vp->drv_flags & HAS_HWCKSM)) ||
+		     (hw_checksums[card_idx] == 1))) {
+			dev->features |= NETIF_F_IP_CSUM;
 		}
 	} else {
 		dev->hard_start_xmit = vortex_start_xmit;
@@ -2811,9 +2813,10 @@ vortex_close(struct net_device *dev)
 	}
 
 #if DO_ZEROCOPY
-	if (	vp->rx_csumhits &&
-			((vp->drv_flags & HAS_HWCKSM) == 0) &&
-			(hw_checksums[vp->card_idx] == -1)) {
+	if (vp->rx_csumhits &&
+	    ((vp->drv_flags & HAS_HWCKSM) == 0) &&
+	    ((vp->card_idx >= MAX_UNITS) ||
+	     (hw_checksums[vp->card_idx] == -1))) {
 		printk(KERN_WARNING "%s supports hardware checksums, and we're not using them!\n", dev->name);
 	}
 #endif
