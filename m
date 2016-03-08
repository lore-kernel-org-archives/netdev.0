From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net] r8169:Remove unnecessary phy reset for pcie nic when setting link spped.
Date: Tue, 8 Mar 2016 16:51:05 +0800
Message-ID: <1457427065-3699-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:32985 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932256AbcCHIxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 03:53:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For pcie nic, after setting link speed and thers is no link  driver does not need
to do phy reset untill link up.

For some pcie nics, to do this will also reset phy speed down counter and prevent
phy from auto speed down.

This patch fix the issue reported in following link.
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1547151

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index dd2cf37..94f08f1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1999,7 +1999,8 @@ static int rtl8169_set_speed(struct net_device *dev,
 		goto out;
 
 	if (netif_running(dev) && (autoneg == AUTONEG_ENABLE) &&
-	    (advertising & ADVERTISED_1000baseT_Full)) {
+	    (advertising & ADVERTISED_1000baseT_Full) &&
+	    !pci_is_pcie(tp->pci_dev)) {
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
 	}
 out:
-- 
1.9.1
