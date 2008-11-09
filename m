From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: atl1: use magic packet wake-on-lan only
Date: Sun, 9 Nov 2008 15:05:30 -0600
Message-ID: <20081109150530.3eb555f9@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, Jie.yang@atheros.com,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:58769 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859AbYKIVFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2008 16:05:36 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2235630wfd.4
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2008 13:05:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

atl1: use magic packet wake-on-lan only

Of the various WOL options provided in include/linux/ethtool.h, the
L1 NIC supports only magic packet.  Remove all options except magic
packet from the atl1 driver.

Signed-off-by: Jay Cliburn <jcliburn@gmail.com>
---
 drivers/net/atlx/atl1.c |   17 +++--------------
 1 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 09ed2fd..611a86e 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -3384,14 +3384,8 @@ static void atl1_get_wol(struct net_device *netdev,
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
-	wol->supported = WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
+	wol->supported = WAKE_MAGIC;
 	wol->wolopts = 0;
-	if (adapter->wol & ATLX_WUFC_EX)
-		wol->wolopts |= WAKE_UCAST;
-	if (adapter->wol & ATLX_WUFC_MC)
-		wol->wolopts |= WAKE_MCAST;
-	if (adapter->wol & ATLX_WUFC_BC)
-		wol->wolopts |= WAKE_BCAST;
 	if (adapter->wol & ATLX_WUFC_MAG)
 		wol->wolopts |= WAKE_MAGIC;
 	return;
@@ -3402,15 +3396,10 @@ static int atl1_set_wol(struct net_device *netdev,
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
-	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+	if (wol->wolopts & (WAKE_PHY | WAKE_UCAST | WAKE_MCAST | WAKE_BCAST |
+		WAKE_ARP | WAKE_MAGICSECURE))
 		return -EOPNOTSUPP;
 	adapter->wol = 0;
-	if (wol->wolopts & WAKE_UCAST)
-		adapter->wol |= ATLX_WUFC_EX;
-	if (wol->wolopts & WAKE_MCAST)
-		adapter->wol |= ATLX_WUFC_MC;
-	if (wol->wolopts & WAKE_BCAST)
-		adapter->wol |= ATLX_WUFC_BC;
 	if (wol->wolopts & WAKE_MAGIC)
 		adapter->wol |= ATLX_WUFC_MAG;
 	return 0;
-- 
1.5.6.5
