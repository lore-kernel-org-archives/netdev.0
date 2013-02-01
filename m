From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next] igb: increase timeout for ethtool offline self-test
Date: Fri,  1 Feb 2013 16:21:35 +0100
Message-ID: <1359732095-17197-1-git-send-email-sassmann@kpanic.de>
Cc: e1000-devel@lists.sourceforge.net, carolyn.wyborny@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751506Ab3BAPWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 10:22:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
1.8.1
