From: Adam Jaremko <adam.jaremko@gmail.com>
Subject: [PATCH v2] net: ftmac100: fix scheduling while atomic during PHY
 link status change
Date: Thu, 28 Apr 2011 13:41:18 -0400
Message-ID: <1304012478.3715.5.camel@localhost.localdomain>
References: <BANLkTi=gcFB4mbmWKu4neep77Jp8R4HWGQ@mail.gmail.com>
	 <BANLkTinB1FiHYX1KoO90UepmhQdXZs0eEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ratbert Po-Yu
	 =?UTF-8?Q?Chuang=28=E8=8E=8A=E5=8D=9A=E5=AE=87=29?=
	<ratbert@faraday-tech.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:42747 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026Ab1D1Rln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 13:41:43 -0400
Received: by ywj3 with SMTP id 3so1050321ywj.19
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 10:41:42 -0700 (PDT)
In-Reply-To: <BANLkTinB1FiHYX1KoO90UepmhQdXZs0eEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think I've sorted my mail client preferences and all should be well now.

Signed-off-by: Adam Jaremko <adam.jaremko@gmail.com>
Acked-by: Po-Yu Chuang <ratbert@faraday-tech.com>
---
 drivers/net/ftmac100.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ftmac100.c b/drivers/net/ftmac100.c
index a316619..9bd7746 100644
--- a/drivers/net/ftmac100.c
+++ b/drivers/net/ftmac100.c
@@ -139,11 +139,11 @@ static int ftmac100_reset(struct ftmac100 *priv)
 			 * that hardware reset completed (what the f*ck).
 			 * We still need to wait for a while.
 			 */
-			usleep_range(500, 1000);
+			udelay(500);
 			return 0;
 		}
 
-		usleep_range(1000, 10000);
+		udelay(1000);
 	}
 
 	netdev_err(netdev, "software reset failed\n");
@@ -772,7 +772,7 @@ static int ftmac100_mdio_read(struct net_device *netdev, int phy_id, int reg)
 		if ((phycr & FTMAC100_PHYCR_MIIRD) == 0)
 			return phycr & FTMAC100_PHYCR_MIIRDATA;
 
-		usleep_range(100, 1000);
+		udelay(100);
 	}
 
 	netdev_err(netdev, "mdio read timed out\n");
@@ -801,7 +801,7 @@ static void ftmac100_mdio_write(struct net_device *netdev, int phy_id, int reg,
 		if ((phycr & FTMAC100_PHYCR_MIIWR) == 0)
 			return;
 
-		usleep_range(100, 1000);
+		udelay(100);
 	}
 
 	netdev_err(netdev, "mdio write timed out\n");
-- 
1.7.4.4

