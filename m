From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 3/3 -mainline] liquidio: off by one in
 liquidio_set_mcast_list()
Date: Sat, 18 Jun 2016 11:50:39 +0300
Message-ID: <20160618085038.GF21713@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29726 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbcFRIuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 04:50:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The nctrl.udd[] array has 32 elements of size u64.

Imagine that netdev_mc_count() returns more than 32.  That means
"mc_count" is 32.  On the last iteration through the loop we have
mc == &nctrl.udd[32] so we're writing one element beyond the end
of the array.

Fixes: f21fb3ed364b ('Add support of Cavium Liquidio ethernet adapters')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 1126422..41ee8bd 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2376,7 +2376,7 @@ static void liquidio_set_mcast_list(struct net_device *netdev)
 		memcpy(((u8 *)mc) + 2, ha->addr, ETH_ALEN);
 		/* no need to swap bytes */
 
-		if (++mc > &nctrl.udd[mc_count])
+		if (++mc >= &nctrl.udd[mc_count])
 			break;
 	}
 
