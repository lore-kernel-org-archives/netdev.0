From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 1/1] Blackfin EMAC driver: Fix Ethernet communication bug (dupliated and lost packets)
Date: Tue, 30 Oct 2007 17:04:09 +0800
Message-ID: <1193735049-7070-1-git-send-email-bryan.wu@analog.com>
Cc: linux-kernel@vger.kernel.org,
	Michael Hennerich <michael.hennerich@analog.com>,
	Bryan Wu <bryan.wu@analog.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:1255 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbXJ3JER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 05:04:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Hennerich <michael.hennerich@analog.com>

Fix Ethernet communication bug(dupliated and lost packets)
in RMII PHY mode- dont call mac_disable and mac_enable during
10/100 REFCLK changes - mac_enable screws up the DMA descriptor chain

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/bfin_mac.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 53fe7de..084acfd 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -371,7 +371,6 @@ static void bf537_adjust_link(struct net_device *dev)
 		if (phydev->speed != lp->old_speed) {
 #if defined(CONFIG_BFIN_MAC_RMII)
 			u32 opmode = bfin_read_EMAC_OPMODE();
-			bf537mac_disable();
 			switch (phydev->speed) {
 			case 10:
 				opmode |= RMII_10;
@@ -386,7 +385,6 @@ static void bf537_adjust_link(struct net_device *dev)
 				break;
 			}
 			bfin_write_EMAC_OPMODE(opmode);
-			bf537mac_enable();
 #endif
 
 			new_state = 1;
-- 
1.5.3.4
