From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 5/8] qlcnic: Fix external loopback test.
Date: Fri, 2 Aug 2013 23:15:58 -0400
Message-ID: <1375499761-21141-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59317 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753915Ab3HCD43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 23:56:29 -0400
In-Reply-To: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Driver was not handling external loopback diagnostic
test request.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 05a847e..7a58e39 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -150,6 +150,7 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Link_Test_on_offline",
 	"Interrupt_Test_offline",
 	"Internal_Loopback_offline",
+	"External_Loopback_offline",
 	"EEPROM_Test_offline"
 };
 
@@ -1026,8 +1027,15 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		if (data[3])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		data[4] = qlcnic_eeprom_test(dev);
-		if (data[4])
+		if (eth_test->flags & ETH_TEST_FL_EXTERNAL_LB) {
+			data[4] = qlcnic_loopback_test(dev, QLCNIC_ELB_MODE);
+			if (data[4])
+				eth_test->flags |= ETH_TEST_FL_FAILED;
+			eth_test->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
+		}
+
+		data[5] = qlcnic_eeprom_test(dev);
+		if (data[5])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 	}
 }
-- 
1.5.6
