From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] lpc_eth: fix error return code in lpc_eth_drv_probe()
Date: Wed, 20 Mar 2013 20:21:48 +0800
Message-ID: <CAPgLHd-49BjXc1pwxhSCExNwTuM9rg4Yj6A2PyqnUq=fgm3YKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	davem@davemloft.net, stigge@antcom.de, edumazet@google.com,
	gregkh@linuxfoundation.org, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:54890 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756568Ab3CTMVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 08:21:49 -0400
Received: by mail-bk0-f52.google.com with SMTP id jk13so799213bkc.11
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 05:21:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/nxp/lpc_eth.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 9c88c00..89d1b0e 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1470,7 +1470,8 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	}
 	platform_set_drvdata(pdev, ndev);
 
-	if (lpc_mii_init(pldat) != 0)
+	ret = lpc_mii_init(pldat);
+	if (ret)
 		goto err_out_unregister_netdev;
 
 	netdev_info(ndev, "LPC mac at 0x%08x irq %d\n",
