From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2 2/4] net: ethoc: don't advertise gigabit speed on attached PHY
Date: Wed, 29 Jan 2014 10:00:16 +0400
Message-ID: <1390975218-13863-3-git-send-email-jcmvbkbc@gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, but does
not disable advertisement when PHY supports them. This results in
non-functioning network when the MAC is connected to a gigabit PHY connected
to a gigabit switch.

The fix is to disable gigabit speed advertisement on attached PHY
unconditionally.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v1->v2:
- disable both gigabit advertisement and support.

 drivers/net/ethernet/ethoc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 4de8cfd..5643b2d 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -688,6 +688,14 @@ static int ethoc_mdio_probe(struct net_device *dev)
 	}
 
 	priv->phy = phy;
+	phy_update_advert(phy,
+			  ADVERTISED_1000baseT_Full |
+			  ADVERTISED_1000baseT_Half, 0);
+	phy_start_aneg(phy);
+	phy_update_supported(phy,
+			     SUPPORTED_1000baseT_Full |
+			     SUPPORTED_1000baseT_Half, 0);
+
 	return 0;
 }
 
-- 
1.8.1.4
