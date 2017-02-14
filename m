From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH v2 1/4] ptp: do not explicitly set drvdata in ptp_clock_register()
Date: Tue, 14 Feb 2017 10:23:31 -0800
Message-ID: <20170214182334.23296-2-dmitry.torokhov@gmail.com>
References: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35712 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751504AbdBNSXi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 13:23:38 -0500
In-Reply-To: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do not need explicitly call dev_set_drvdata(), as it is done for us by
device_create().

Acked-by: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/ptp/ptp_clock.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 9c13381b6966..b4e5e8022c29 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -227,8 +227,6 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 	if (IS_ERR(ptp->dev))
 		goto no_device;
 
-	dev_set_drvdata(ptp->dev, ptp);
-
 	err = ptp_populate_sysfs(ptp);
 	if (err)
 		goto no_sysfs;
-- 
2.11.0.483.g087da7b7c-goog
