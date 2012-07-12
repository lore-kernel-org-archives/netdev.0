From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] qlge: fix an "&&" vs "||" bug
Date: Thu, 12 Jul 2012 17:47:03 +0300
Message-ID: <20120712144702.GB24202@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:19674 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933965Ab2GLOrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:47:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The condition is always true so WOL will never work.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 3d4462b..6f316ab 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -440,7 +440,7 @@ static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 	unsigned short ssys_dev = qdev->pdev->subsystem_device;
 
 	/* WOL is only supported for mezz card. */
-	if (ssys_dev != QLGE_MEZZ_SSYS_ID_068 ||
+	if (ssys_dev != QLGE_MEZZ_SSYS_ID_068 &&
 			ssys_dev != QLGE_MEZZ_SSYS_ID_180) {
 		netif_info(qdev, drv, qdev->ndev,
 				"WOL is only supported for mezz card\n");
