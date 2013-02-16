From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] igb: increase timeout for ethtool offline self-test
Date: Sat, 16 Feb 2013 00:33:25 -0800
Message-ID: <1361003616-3422-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14939 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752364Ab3BPIdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:43 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

On several machines with i350 adapters the ethtool offline self-test sometimes
fails. This happens because link auto negotiation may take longer than the
timeout of 4 seconds. Increasing the timeout by 1 seconds resolves the issue.

Output from a failing i350 offline self-test:
while [ 1 ]; do ethtool -t eth2 offline; done
The test result is PASS
The test extra info:
Register test  (offline)         0
Eeprom test    (offline)         0
Interrupt test (offline)         0
Loopback test  (offline)         0
Link test   (on/offline)         0

The test result is FAIL
The test extra info:
Register test  (offline)         0
Eeprom test    (offline)         0
Interrupt test (offline)         0
Loopback test  (offline)         0
Link test   (on/offline)         1

The test result is PASS
The test extra info:
Register test  (offline)         0
Eeprom test    (offline)         0
Interrupt test (offline)         0
Loopback test  (offline)         0
Link test   (on/offline)         0

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 40b5d56..a3830a8 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1891,7 +1891,7 @@ static int igb_link_test(struct igb_adapter *adapter, u64 *data)
 	} else {
 		hw->mac.ops.check_for_link(&adapter->hw);
 		if (hw->mac.autoneg)
-			msleep(4000);
+			msleep(5000);
 
 		if (!(rd32(E1000_STATUS) & E1000_STATUS_LU))
 			*data = 1;
-- 
1.7.11.7
