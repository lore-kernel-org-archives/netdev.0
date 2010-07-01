From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/5] igb: correct link test not being run when
	link is down
Date: Thu, 01 Jul 2010 16:39:01 -0700
Message-ID: <20100701233859.16171.45966.stgit@localhost.localdomain>
References: <20100701233733.16171.4629.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:41421 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753101Ab0GAXjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:39:20 -0400
In-Reply-To: <20100701233733.16171.4629.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb online link test was always reporting pass because instead of
checking for if_running it was checking for netif_carrier_ok.

This change corrects the test so that it is run if the interface is running
instead of checking for netif carrier ok.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index f2ebf92..26bf6a1 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1823,12 +1823,10 @@ static void igb_diag_test(struct net_device *netdev,
 		dev_info(&adapter->pdev->dev, "online testing starting\n");
 
 		/* PHY is powered down when interface is down */
-		if (!netif_carrier_ok(netdev)) {
+		if (if_running && igb_link_test(adapter, &data[4]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+		else
 			data[4] = 0;
-		} else {
-			if (igb_link_test(adapter, &data[4]))
-				eth_test->flags |= ETH_TEST_FL_FAILED;
-		}
 
 		/* Online tests aren't run; pass by default */
 		data[0] = 0;

