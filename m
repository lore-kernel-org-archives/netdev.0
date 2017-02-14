From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH 2/4] ptp: use kcalloc/kmallco_array when allocating arrays
Date: Mon, 13 Feb 2017 19:51:06 -0800
Message-ID: <20170214035108.19622-2-dmitry.torokhov@gmail.com>
References: <20170214035108.19622-1-dmitry.torokhov@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214035108.19622-1-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kcalloc/kmalloc_array are more semantically correct when allocating arrays
of objects, and overflow-safe.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/ptp/ptp_sysfs.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/ptp/ptp_sysfs.c b/drivers/ptp/ptp_sysfs.c
index 53d43954a974..77843790c381 100644
--- a/drivers/ptp/ptp_sysfs.c
+++ b/drivers/ptp/ptp_sysfs.c
@@ -269,13 +269,13 @@ static int ptp_populate_pins(struct ptp_clock *ptp)
 	struct ptp_clock_info *info = ptp->info;
 	int err = -ENOMEM, i, n_pins = info->n_pins;
 
-	ptp->pin_dev_attr = kzalloc(n_pins * sizeof(*ptp->pin_dev_attr),
+	ptp->pin_dev_attr = kcalloc(n_pins, sizeof(*ptp->pin_dev_attr),
 				    GFP_KERNEL);
 	if (!ptp->pin_dev_attr)
 		goto no_dev_attr;
 
-	ptp->pin_attr = kzalloc((1 + n_pins) * sizeof(struct attribute *),
-				GFP_KERNEL);
+	ptp->pin_attr = kmalloc_array(1 + n_pins, sizeof(*ptp->pin_attr),
+				      GFP_KERNEL);
 	if (!ptp->pin_attr)
 		goto no_pin_attr;
 
@@ -289,6 +289,9 @@ static int ptp_populate_pins(struct ptp_clock *ptp)
 		ptp->pin_attr[i] = &da->attr;
 	}
 
+	/* NULL terminator */
+	ptp->pin_attr[n_pins] = NULL;
+
 	ptp->pin_attr_group.name = "pins";
 	ptp->pin_attr_group.attrs = ptp->pin_attr;
 
-- 
2.11.0.483.g087da7b7c-goog
