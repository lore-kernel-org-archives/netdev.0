From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 2/3] qlcnic: Fix beacon state return status handling
Date: Thu, 15 Aug 2013 08:29:28 -0400
Message-ID: <1376569769-625-3-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1376569769-625-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40836 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755403Ab3HONEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:04:07 -0400
In-Reply-To: <1376569769-625-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Driver was misinterpreting the return status for beacon
  state query leading to incorrect interpretation of beacon
  state and logging an error message for successful status.
  Fixed the driver to properly interpret the return status.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 10ed82b..660c3f5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -170,9 +170,9 @@ static int qlcnic_82xx_store_beacon(struct qlcnic_adapter *adapter,
 
 	if (ahw->extra_capability[0] & QLCNIC_FW_CAPABILITY_2_BEACON) {
 		err = qlcnic_get_beacon_state(adapter, &h_beacon_state);
-		if (!err) {
-			dev_info(&adapter->pdev->dev,
-				 "Failed to get current beacon state\n");
+		if (err) {
+			netdev_err(adapter->netdev,
+				   "Failed to get current beacon state\n");
 		} else {
 			if (h_beacon_state == QLCNIC_BEACON_DISABLE)
 				ahw->beacon_state = 0;
-- 
1.8.1.4
