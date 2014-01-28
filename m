From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 4/4] qlcnic: Fix loopback test failure
Date: Tue, 28 Jan 2014 11:55:30 -0500
Message-ID: <1390928130-10710-5-git-send-email-rajesh.borundia@qlogic.com>
References: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:48211 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755201AbaA1RaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 12:30:06 -0500
In-Reply-To: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Driver was returning from link event handler without
setting linkup variable

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 19e1a93..54ebf30 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -683,12 +683,17 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 		adapter->ahw->linkup = 0;
 		netif_carrier_off(netdev);
 	} else if (!adapter->ahw->linkup && linkup) {
-		/* Do not advertise Link up if the port is in loopback mode */
-		if (qlcnic_83xx_check(adapter) && adapter->ahw->lb_mode)
+		adapter->ahw->linkup = 1;
+
+		/* Do not advertise Link up to the stack if device
+		 * is in loopback mode
+		 */
+		if (qlcnic_83xx_check(adapter) && adapter->ahw->lb_mode) {
+			netdev_info(netdev, "NIC Link is up for loopback test\n");
 			return;
+		}
 
 		netdev_info(netdev, "NIC Link is up\n");
-		adapter->ahw->linkup = 1;
 		netif_carrier_on(netdev);
 	}
 }
-- 
1.5.6
