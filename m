From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v3 1/2] net: ethoc: don't advertise gigabit speed on attached PHY
Date: Tue,  4 Feb 2014 03:33:09 +0400
Message-ID: <1391470390-31569-2-git-send-email-jcmvbkbc@gmail.com>
References: <1391470390-31569-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34453 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754350AbaBCXdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 18:33:43 -0500
Received: by mail-lb0-f179.google.com with SMTP id l4so5762639lbv.24
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 15:33:42 -0800 (PST)
In-Reply-To: <1391470390-31569-1-git-send-email-jcmvbkbc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, but does
not disable advertisement when PHY supports them. This results in
non-functioning network when the MAC is connected to a gigabit PHY connected
to a gigabit switch.

The fix is to disable gigabit speed advertisement on attached PHY
unconditionally.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v2->v3:
- don't call phy_start_aneg to force phylib to disable gigabit advertisement.

Changes v1->v2:
- disable both gigabit advertisement and support.

 drivers/net/ethernet/ethoc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 5ca7719..6aef639 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -691,6 +691,11 @@ static int ethoc_mdio_probe(struct net_device *dev)
 	}
 
 	priv->phy = phy;
+	phy->advertising &= ~(ADVERTISED_1000baseT_Full |
+			      ADVERTISED_1000baseT_Half);
+	phy->supported &= ~(SUPPORTED_1000baseT_Full |
+			    SUPPORTED_1000baseT_Half);
+
 	return 0;
 }
 
-- 
1.8.1.4
