From: Colin King <colin.king@canonical.com>
Subject: [PATCH][next] net: phy: mdio-bcm-unimac: fix unsigned wrap-around when decrementing timeout
Date: Tue,  8 Aug 2017 10:52:32 +0100
Message-ID: <20170808095232.13490-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Change post-decrement compare to pre-decrement to avoid an
unsigned integer wrap-around on timeout. This leads to the following
!timeout check to never to be true so -ETIMEDOUT is never returned.

Detected by CoverityScan, CID#1452623 ("Logically dead code")

Fixes: 69a60b0579a4 ("net: phy: mdio-bcm-unimac: factor busy polling loop")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/phy/mdio-bcm-unimac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index 89425ca48412..73c5267a11fd 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -71,7 +71,7 @@ static int unimac_mdio_poll(void *wait_func_data)
 			return 0;
 
 		usleep_range(1000, 2000);
-	} while (timeout--);
+	} while (--timeout);
 
 	if (!timeout)
 		return -ETIMEDOUT;
-- 
2.11.0
