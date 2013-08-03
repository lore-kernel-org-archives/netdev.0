From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 6/8] qlcnic: Fix link speed display for 82xx adapter
Date: Fri, 2 Aug 2013 23:15:59 -0400
Message-ID: <1375499761-21141-7-git-send-email-shahed.shaikh@qlogic.com>
References: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:60283 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746Ab3HCEF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 00:05:29 -0400
In-Reply-To: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Do not obtain link speed from register when adapter
  link is down.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 7a58e39..ac42cde 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -301,9 +301,13 @@ int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
 		}
 
 		if (netif_running(adapter->netdev) && ahw->has_link_events) {
-			reg = QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn));
-			speed = P3P_LINK_SPEED_VAL(pcifn, reg);
-			ahw->link_speed = speed * P3P_LINK_SPEED_MHZ;
+			if (ahw->linkup) {
+				reg = QLCRD32(adapter,
+					      P3P_LINK_SPEED_REG(pcifn));
+				speed = P3P_LINK_SPEED_VAL(pcifn, reg);
+				ahw->link_speed = speed * P3P_LINK_SPEED_MHZ;
+			}
+
 			ethtool_cmd_speed_set(ecmd, ahw->link_speed);
 			ecmd->autoneg = ahw->link_autoneg;
 			ecmd->duplex = ahw->link_duplex;
-- 
1.5.6
