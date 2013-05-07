From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] sfc: fix return value check in efx_ptp_probe_channel()
Date: Tue, 7 May 2013 20:19:25 +0800
Message-ID: <CAPgLHd9-6uOYFs5PVSmxGmPBidtWNWk9ZK6O8s7_6KWQihu=4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: linux-net-drivers@solarflare.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:62114 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755969Ab3EGMT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 08:19:26 -0400
Received: by mail-bk0-f45.google.com with SMTP id je9so248875bkc.4
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 05:19:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function ptp_clock_register() returns ERR_PTR()
and never returns NULL. The NULL test in the return value check should
be replaced with IS_ERR().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/sfc/ptp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 07f6baa..9a95abf 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -912,8 +912,10 @@ static int efx_ptp_probe_channel(struct efx_channel *channel)
 
 	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
 					    &efx->pci_dev->dev);
-	if (!ptp->phc_clock)
+	if (IS_ERR(ptp->phc_clock)) {
+		rc = PTR_ERR(ptp->phc_clock);
 		goto fail3;
+	}
 
 	INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
 	ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
