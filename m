From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] tulip: cleanup by using ARRAY_SIZE()
Date: Thu, 23 Jan 2014 11:26:37 +0300
Message-ID: <20140123082637.GC28688@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In this situation then ARRAY_SIZE() and sizeof() are the same, but we're
really dealing with array indexes and not byte offsets so ARRAY_SIZE()
is cleaner.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/dec/tulip/media.c b/drivers/net/ethernet/dec/tulip/media.c
index 0d0ba725341a..dcf21a36a9cf 100644
--- a/drivers/net/ethernet/dec/tulip/media.c
+++ b/drivers/net/ethernet/dec/tulip/media.c
@@ -457,7 +457,7 @@ void tulip_find_mii(struct net_device *dev, int board_idx)
 	/* Find the connected MII xcvrs.
 	   Doing this in open() would allow detecting external xcvrs later,
 	   but takes much time. */
-	for (phyn = 1; phyn <= 32 && phy_idx < sizeof (tp->phys); phyn++) {
+	for (phyn = 1; phyn <= 32 && phy_idx < ARRAY_SIZE(tp->phys); phyn++) {
 		int phy = phyn & 0x1f;
 		int mii_status = tulip_mdio_read (dev, phy, MII_BMSR);
 		if ((mii_status & 0x8301) == 0x8001 ||
