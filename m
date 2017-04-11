From: Fugang Duan <fugang.duan@nxp.com>
Subject: [PATCH net-next 1/6] net: fec: add return value check after calling .of_property_read_u32()
Date: Tue, 11 Apr 2017 19:13:03 +0800
Message-ID: <1491909188-8971-2-git-send-email-fugang.duan@nxp.com>
References: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
        <stephen@networkplumber.org>, <fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0063.outbound.protection.outlook.com ([104.47.36.63]:11776
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753246AbdDKLPT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 07:15:19 -0400
In-Reply-To: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add return value check after calling .of_property_read_u32() to avoid
the warning reported by coverity.

Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 91a1664..886a9c9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3197,9 +3197,9 @@ static void fec_reset_phy(struct platform_device *pdev)
 	if (!np)
 		return;
 
-	of_property_read_u32(np, "phy-reset-duration", &msec);
+	err = of_property_read_u32(np, "phy-reset-duration", &msec);
 	/* A sane reset duration should not be longer than 1s */
-	if (msec > 1000)
+	if (!err && msec > 1000)
 		msec = 1;
 
 	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
-- 
1.9.1
