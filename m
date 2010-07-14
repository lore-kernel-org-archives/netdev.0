From: amit.salecha@qlogic.com
Subject: [PATCHv3 NEXT 1/5] qlcnic: fix pause params setting
Date: Tue, 13 Jul 2010 23:33:31 -0700
Message-ID: <1279089215-23231-2-git-send-email-amit.salecha@qlogic.com>
References: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:13444 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752378Ab0GNGdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 02:33:36 -0400
In-Reply-To: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

Turning off rx pause param and autoneg param is not supported so
return error in that case.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index baf5a52..7d6558e 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -578,8 +578,12 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		}
 		QLCWR32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, val);
 	} else if (adapter->ahw.port_type == QLCNIC_XGBE) {
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

