From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH 1/3] net: ethoc: don't advertise gigabit speed on attached PHY
Date: Mon, 27 Jan 2014 07:59:25 +0400
Message-ID: <1390795167-6677-2-git-send-email-jcmvbkbc@gmail.com>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
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
 drivers/net/ethernet/ethoc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 4de8cfd..0aa1a05 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -712,6 +712,8 @@ static int ethoc_open(struct net_device *dev)
 		netif_start_queue(dev);
 	}
 
+	priv->phy->advertising &= ~(ADVERTISED_1000baseT_Full |
+				    ADVERTISED_1000baseT_Half);
 	phy_start(priv->phy);
 	napi_enable(&priv->napi);
 
-- 
1.8.1.4
