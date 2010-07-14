From: amit.salecha@qlogic.com
Subject: [PATCHv2 NEXT 1/5] qlcnic: fix pause params setting
Date: Tue, 13 Jul 2010 22:54:49 -0700
Message-ID: <1279086893-22523-2-git-send-email-amit.salecha@qlogic.com>
References: <1279086893-22523-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:39795 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750959Ab0GNFyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 01:54:53 -0400
In-Reply-To: <1279086893-22523-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

Turning off rx pause param and autoneg param is not supported so
return error in that case.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index baf5a52..8599993 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -578,8 +578,13 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		}
 		QLCWR32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, val);
 	} else if (adapter->ahw.port_type == QLCNIC_XGBE) {
+
+		if (!pause->rx_pause || pause->autoneg)
+			return -EOPNOTSUPP;
+
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return -EIO;
+
 		val = QLCRD32(adapter, QLCNIC_NIU_XG_PAUSE_CTL);
 		if (port == 0) {
 			if (pause->tx_pause)
-- 
1.6.0.2

