From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next PATCH 1/2] be2net: ethtool self test reorganization.
Date: Tue, 19 Jan 2010 20:45:00 +0530
Message-ID: <20100119151450.GA8250@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:33946 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753212Ab0ASPPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 10:15:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ddr dma ethtool self test needs to be performed even when ETH_TEST_FL_OFFLINE is not set.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_ethtool.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index f18c02f..2f2ebbd 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -545,10 +545,11 @@ be_self_test(struct net_device *netdev, 
 						&data[2]) != 0) {
 			test->flags |= ETH_TEST_FL_FAILED;
 		}
+	}
 
-		data[3] = be_test_ddr_dma(adapter);
-		if (data[3] != 0)
-			test->flags |= ETH_TEST_FL_FAILED;
+	if (be_test_ddr_dma(adapter) != 0) {
+		data[3] = 1;
+		test->flags |= ETH_TEST_FL_FAILED;
 	}
 
 }
-- 
1.4.0

