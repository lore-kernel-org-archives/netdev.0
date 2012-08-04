From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 2/3] igb: correct hardware type (i210/i211) check in igb_loopback_test()
Date: Sat,  4 Aug 2012 03:25:51 -0700
Message-ID: <1344075952-4198-3-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1344075952-4198-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Jesper Juhl <jj@chaosbits.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44124 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751790Ab2HDK0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2012 06:26:31 -0400
In-Reply-To: <1344075952-4198-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Juhl <jj@chaosbits.net>

In the original code
...
 	if ((adapter->hw.mac.type == e1000_i210)
		|| (adapter->hw.mac.type == e1000_i210)) {
...
the second check of 'adapter->hw.mac.type' is pointless since it tests
for the exact same value as the first.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Acked-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index a19c84c..ad489b7 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1783,7 +1783,7 @@ static int igb_loopback_test(struct igb_adapter *adapter, u64 *data)
 		goto out;
 	}
 	if ((adapter->hw.mac.type == e1000_i210)
-		|| (adapter->hw.mac.type == e1000_i210)) {
+		|| (adapter->hw.mac.type == e1000_i211)) {
 		dev_err(&adapter->pdev->dev,
 			"Loopback test not supported "
 			"on this part at this time.\n");
-- 
1.7.10.4
