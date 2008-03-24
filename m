From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] Fix frame size calculation when hardware VLAN acceleration is on
Date: Mon, 24 Mar 2008 10:53:26 -0500
Message-ID: <1206374009-1292-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:47257 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbYCXPxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 11:53:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dai Haruki <dai.haruki@freescale.com>

In gfar_change_mtu(), the frame size needs to be increased to account for the
extra 4 bytes VLAN adds to the ethernet header.  However, it was being increased
by the length of the whole header (18 bytes), which is wrong.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 718cf77..0ab4b26 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1185,7 +1185,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	int frame_size = new_mtu + ETH_HLEN;
 
 	if (priv->vlan_enable)
-		frame_size += VLAN_ETH_HLEN;
+		frame_size += VLAN_HLEN;
 
 	if (gfar_uses_fcb(priv))
 		frame_size += GMAC_FCB_LEN;
-- 
1.5.4.23.gef5b9

