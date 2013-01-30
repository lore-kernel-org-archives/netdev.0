From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 6/8] qlcnic: Fix RX/TX checksum setting for some adapter types
Date: Wed, 30 Jan 2013 17:47:17 -0500
Message-ID: <1359586039-19051-7-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Manish chopra <manish.chopra@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:40086 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932098Ab3A3XIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 18:08:30 -0500
In-Reply-To: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 4e4ebaf..88a2330 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -932,7 +932,8 @@ netdev_features_t qlcnic_fix_features(struct net_device *netdev,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
-	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
+	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) &&
+	    qlcnic_82xx_check(adapter)) {
 		netdev_features_t changed = features ^ netdev->features;
 		features ^= changed & (NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
 	}
-- 
1.7.1
