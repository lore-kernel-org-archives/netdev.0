From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH v2 2/4] ptp: use kcalloc when allocating arrays
Date: Tue, 14 Feb 2017 10:23:32 -0800
Message-ID: <20170214182334.23296-3-dmitry.torokhov@gmail.com>
References: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:32997 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbdBNSXk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 13:23:40 -0500
In-Reply-To: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kcalloc is more semantically correct when allocating arrays of objects, and
overflow-safe.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/ptp/ptp_sysfs.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/ptp/ptp_sysfs.c b/drivers/ptp/ptp_sysfs.c
index 53d43954a974..27cd46ab5e32 100644
--- a/drivers/ptp/ptp_sysfs.c
+++ b/drivers/ptp/ptp_sysfs.c
@@ -269,13 +269,12 @@ static int ptp_populate_pins(struct ptp_clock *ptp)
 	struct ptp_clock_info *info = ptp->info;
 	int err = -ENOMEM, i, n_pins = info->n_pins;
 
-	ptp->pin_dev_attr = kzalloc(n_pins * sizeof(*ptp->pin_dev_attr),
+	ptp->pin_dev_attr = kcalloc(n_pins, sizeof(*ptp->pin_dev_attr),
 				    GFP_KERNEL);
 	if (!ptp->pin_dev_attr)
 		goto no_dev_attr;
 
-	ptp->pin_attr = kzalloc((1 + n_pins) * sizeof(struct attribute *),
-				GFP_KERNEL);
+	ptp->pin_attr = kcalloc(1 + n_pins, sizeof(*ptp->pin_attr), GFP_KERNEL);
 	if (!ptp->pin_attr)
 		goto no_pin_attr;
 
-- 
2.11.0.483.g087da7b7c-goog
