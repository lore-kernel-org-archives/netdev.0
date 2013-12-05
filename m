From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 2/3] qlge: Allow enable/disable rx/tx vlan acceleration independently
Date: Thu, 5 Dec 2013 18:11:23 -0500
Message-ID: <1386285084-25250-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1386285084-25250-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:27411 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753644Ab3LEXoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:44:05 -0500
In-Reply-To: <1386285084-25250-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o Fix the driver to allow user to enable/disable rx/tx vlan acceleration independently.

  For example:
	ethtool -K ethX rxvlan on/off
	ethtool -K ethX txvlan on/off

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index a245dc1..449f506 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2376,14 +2376,6 @@ static netdev_features_t qlge_fix_features(struct net_device *ndev,
 	netdev_features_t features)
 {
 	int err;
-	/*
-	 * Since there is no support for separate rx/tx vlan accel
-	 * enable/disable make sure tx flag is always in same state as rx.
-	 */
-	if (features & NETIF_F_HW_VLAN_CTAG_RX)
-		features |= NETIF_F_HW_VLAN_CTAG_TX;
-	else
-		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
 
 	/* Update the behavior of vlan accel in the adapter */
 	err = qlge_update_hw_vlan_features(ndev, features);
-- 
1.7.6.rc1.1.g2c162b
