From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] cavium/liquidio: fix some error handling in
 lio_set_phys_id()
Date: Wed, 24 Jun 2015 17:47:02 +0300
Message-ID: <20150624144702.GH1702@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There was a missing assignment so the "if (ret)" on the next line is
never true.

Fixes: f21fb3ed364b ('Add support of Cavium Liquidio ethernet adapters')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 160f807..29f3308 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -434,8 +434,9 @@ static int lio_set_phys_id(struct net_device *netdev,
 			if (ret)
 				return ret;
 
-			octnet_mdio45_access(lio, 1, LIO68XX_LED_BEACON_ADDR,
-					     &lio->phy_beacon_val);
+			ret = octnet_mdio45_access(lio, 1,
+						   LIO68XX_LED_BEACON_ADDR,
+						   &lio->phy_beacon_val);
 			if (ret)
 				return ret;
 
