From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] r8169: allow multicast packets on sub-8168f chipset.
Date: Thu, 1 Nov 2012 23:08:47 +0100
Message-ID: <20121101220847.GA7708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Nathan Walp <faceprint@faceprint.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47249 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762452Ab2KAWay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 18:30:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Walp <faceprint@faceprint.com>

RTL_GIGA_MAC_VER_35 includes no multicast hardware filter.

Signed-off-by: Nathan Walp <faceprint@faceprint.com>
Suggested-by: Hayes Wang <hayeswang@realtek.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e7ff886..89bf6e1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4519,6 +4519,9 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		mc_filter[1] = swab32(data);
 	}
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_35)
+		mc_filter[1] = mc_filter[0] = 0xffffffff;
+
 	RTL_W32(MAR0 + 4, mc_filter[1]);
 	RTL_W32(MAR0 + 0, mc_filter[0]);
 
-- 
1.7.11.7
