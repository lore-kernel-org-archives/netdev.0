From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] gianfar: add missing iounmap() on error in gianfar_ptp_probe()
Date: Fri, 17 May 2013 16:25:34 +0800
Message-ID: <CAPgLHd9ED7YCCTmKtD9PURq_cWy5GG=M+4ExC1wd+xOpgB97CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: richardcochran@gmail.com, grant.likely@linaro.org,
	rob.herring@calxeda.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:47922 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720Ab3EQIZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:25:35 -0400
Received: by mail-bk0-f47.google.com with SMTP id jg9so2157002bkc.20
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 01:25:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Add the missing iounmap() before return from gianfar_ptp_probe()
in the error handling case.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 576e4b8..083ea2b 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -524,6 +524,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 	return 0;
 
 no_clock:
+	iounmap(etsects->regs);
 no_ioremap:
 	release_resource(etsects->rsrc);
 no_resource:
