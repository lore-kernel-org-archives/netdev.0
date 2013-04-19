From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 2/3] qlge: Fix ethtool autoneg advertising.
Date: Fri, 19 Apr 2013 01:49:53 -0400
Message-ID: <1366350594-21973-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1366350594-21973-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:5074 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756330Ab3DSGNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 02:13:52 -0400
In-Reply-To: <1366350594-21973-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Autoneg is supported on specific port types only. Fix the driver to advertise
autoneg based on the port type.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 6f316ab..0780e03 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -379,13 +379,13 @@ static int ql_get_settings(struct net_device *ndev,
 
 	ecmd->supported = SUPPORTED_10000baseT_Full;
 	ecmd->advertising = ADVERTISED_10000baseT_Full;
-	ecmd->autoneg = AUTONEG_ENABLE;
 	ecmd->transceiver = XCVR_EXTERNAL;
 	if ((qdev->link_status & STS_LINK_TYPE_MASK) ==
 				STS_LINK_TYPE_10GBASET) {
 		ecmd->supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
 		ecmd->advertising |= (ADVERTISED_TP | ADVERTISED_Autoneg);
 		ecmd->port = PORT_TP;
+		ecmd->autoneg = AUTONEG_ENABLE;
 	} else {
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
-- 
1.7.6.rc1.1.g2c162b
