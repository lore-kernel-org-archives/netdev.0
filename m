From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] tg3: Fix temperature reporting
Date: Tue, 1 Sep 2015 18:07:41 +0200
Message-ID: <20150901180741.1451e146@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43156 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753616AbbIAQHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 12:07:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The temperature registers appear to report values in degrees Celsius
while the hwmon API mandates values to be exposed in millidegrees
Celsius. Do the conversion so that the values reported by "sensors"
are correct.

Fixes: aed93e0bf493 ("tg3: Add hwmon support for temperature")
Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Prashant Sreedharan <prashant@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: stable@vger.kernel.org [v3.6+]
---
 drivers/net/ethernet/broadcom/tg3.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-4.2.orig/drivers/net/ethernet/broadcom/tg3.c	2015-09-01 17:38:59.786648348 +0200
+++ linux-4.2/drivers/net/ethernet/broadcom/tg3.c	2015-09-01 17:47:14.237152813 +0200
@@ -10757,7 +10757,7 @@ static ssize_t tg3_show_temp(struct devi
 	tg3_ape_scratchpad_read(tp, &temperature, attr->index,
 				sizeof(temperature));
 	spin_unlock_bh(&tp->lock);
-	return sprintf(buf, "%u\n", temperature);
+	return sprintf(buf, "%u\n", temperature * 1000);
 }
 
 

-- 
Jean Delvare
SUSE L3 Support
