From: Andrew Lunn <andrew@lunn.ch>
Subject: FWD: [PATCH][next] net: phy: mdio-bcm-unimac: fix unsigned
 wrap-around when decrementing timeout
Date: Tue, 8 Aug 2017 16:07:55 +0200
Message-ID: <20170808140755.GB2015@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: colin.king@canonical.com, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56369 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752104AbdHHOH5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 10:07:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Forwarded message from Colin King <colin.king@canonical.com> -----

Date: Tue,  8 Aug 2017 10:52:32 +0100
From: Colin King <colin.king@canonical.com>
To: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH][next] net: phy: mdio-bcm-unimac: fix unsigned wrap-around when decrementing timeout
X-Spam-Status: No, score=-7.4 required=4.0 tests=BAYES_00,RCVD_IN_DNSWL_HI, RP_MATCHES_RCVD,T_HEADER_FROM_DIFFERENT_DOMAINS autolearn=ham
	autolearn_force=no version=3.4.0

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


----- End forwarded message -----

Hi Florian

You might want to look at bcm_sf2_cfp_op() and bcm_sf2_cfp_rst().

Colin, do you have more of these patches? Have you done a tree wide
search?

       Andrew
