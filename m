From: weiyj_lk@163.com
Subject: [PATCH -next] net: ethernet: bgmac: Fix return value check in bgmac_probe()
Date: Tue, 12 Jul 2016 00:17:28 +0000
Message-ID: <1468282648-1746-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jon Mason <jon.mason@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:44156 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932088AbcGLARu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 20:17:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function devm_ioremap_resource() returns ERR_PTR()
and never returns NULL. The NULL test in the return value check should be
replaced with IS_ERR().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/broadcom/bgmac-platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-platform.c b/drivers/net/ethernet/broadcom/bgmac-platform.c
index 7a8f7ef..1a2d841 100644
--- a/drivers/net/ethernet/broadcom/bgmac-platform.c
+++ b/drivers/net/ethernet/broadcom/bgmac-platform.c
@@ -141,7 +141,7 @@ static int bgmac_probe(struct platform_device *pdev)
 	}
 
 	bgmac->plat.idm_base = devm_ioremap_resource(&pdev->dev, regs);
-	if (!bgmac->plat.idm_base) {
+	if (IS_ERR(bgmac->plat.idm_base)) {
 		dev_err(&pdev->dev, "Unable to map idm resource\n");
 		return PTR_ERR(bgmac->plat.idm_base);
 	}
