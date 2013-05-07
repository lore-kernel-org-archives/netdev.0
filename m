From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 27/36] net: ethernet: stmicro: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 14:09:02 +0900
Message-ID: <003601ce4ae0$fd6bc030$f8434090$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Giuseppe Cavallaro' <peppe.cavallaro@st.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:9990 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758436Ab3EGFJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:09:04 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00J1WWXSZ870@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 14:09:02 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1d3780f..17bc782 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -171,8 +171,6 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 	if (priv->plat->exit)
 		priv->plat->exit(pdev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	return ret;
 }
 
-- 
1.7.2.5
