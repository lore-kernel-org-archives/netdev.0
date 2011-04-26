From: Adam Jaremko <adam.jaremko@gmail.com>
Subject: [PATCH] net: ftmac100: fix scheduling while atomic during PHY link
 status change
Date: Tue, 26 Apr 2011 12:32:56 -0400
Message-ID: <BANLkTi=gcFB4mbmWKu4neep77Jp8R4HWGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ratbert.chuang@gmail.com, netdev@vger.kernel.org
To: =?UTF-8?B?UmF0YmVydCBQby1ZdSBDaHVhbmco6I6K5Y2a5a6HKQ==?=
	<ratbert@faraday-tech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:43355 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab1DZQc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 12:32:57 -0400
Received: by gyd10 with SMTP id 10so285024gyd.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 09:32:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Adam Jaremko <adam.jaremko@gmail.com>
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
@@ -772,7 +772,7 @@ static int ftmac100_mdio_read(struct net_device
*netdev, int phy_id, int reg)
 		if ((phycr & FTMAC100_PHYCR_MIIRD) == 0)
 			return phycr & FTMAC100_PHYCR_MIIRDATA;

-		usleep_range(100, 1000);
+		udelay(100);
 	}

 	netdev_err(netdev, "mdio read timed out\n");
@@ -801,7 +801,7 @@ static void ftmac100_mdio_write(struct net_device
*netdev, int phy_id, int reg,
 		if ((phycr & FTMAC100_PHYCR_MIIWR) == 0)
 			return;

-		usleep_range(100, 1000);
+		udelay(100);
 	}

 	netdev_err(netdev, "mdio write timed out\n");
-- 
1.7.4.4
