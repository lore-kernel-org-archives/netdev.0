From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ptp_pch: fix error handling in pch_probe()
Date: Thu, 23 May 2013 17:59:28 +0800
Message-ID: <CAPgLHd-ec4mveiMefnkSYLNnhYizt6_xZ7ZNLR9YxZCciMH+gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:33557 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757636Ab3EWJ73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 05:59:29 -0400
Received: by mail-bk0-f52.google.com with SMTP id mz10so1688460bkb.39
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 02:59:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to release resources when ptp_clock_register() fail instead
of return error code directly.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/ptp/ptp_pch.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index bea9451..71a2559 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -628,9 +628,10 @@ pch_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	chip->caps = ptp_pch_caps;
 	chip->ptp_clock = ptp_clock_register(&chip->caps, &pdev->dev);
-
-	if (IS_ERR(chip->ptp_clock))
-		return PTR_ERR(chip->ptp_clock);
+	if (IS_ERR(chip->ptp_clock)) {
+		ret = PTR_ERR(chip->ptp_clock);
+		goto err_ptp_clock_reg;
+	}
 
 	spin_lock_init(&chip->register_lock);
 
@@ -669,6 +670,7 @@ pch_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 err_req_irq:
 	ptp_clock_unregister(chip->ptp_clock);
+err_ptp_clock_reg:
 	iounmap(chip->regs);
 	chip->regs = NULL;
 
