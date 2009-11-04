From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 06/12] wimax/i2400m: Fix USB timeout specifications (to ms from HZ)
Date: Wed,  4 Nov 2009 13:40:11 -0800
Message-ID: <296bd4bdd0a43c5e56ee310bcb9b4722e5d52db8.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28863 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932798AbZKDVmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:20 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The USB code was incorrectly specifiying timeouts to be in jiffies vs
msecs. On top of that, lower it to 200ms, as 1s is really too long
(doesn't allow the watchdog to trip a reset if the device timesout too
often).

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb-fw.c |    2 +-
 drivers/net/wimax/i2400m/usb-rx.c |    2 +-
 drivers/net/wimax/i2400m/usb-tx.c |    2 +-
 drivers/net/wimax/i2400m/usb.c    |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb-fw.c b/drivers/net/wimax/i2400m/usb-fw.c
index b59aee0..8ec8b6d 100644
--- a/drivers/net/wimax/i2400m/usb-fw.c
+++ b/drivers/net/wimax/i2400m/usb-fw.c
@@ -102,7 +102,7 @@ ssize_t i2400mu_tx_bulk_out(struct i2400mu *i2400mu, void *buf, size_t buf_size)
 	epd = usb_get_epd(i2400mu->usb_iface, i2400mu->endpoint_cfg.bulk_out);
 	pipe = usb_sndbulkpipe(i2400mu->usb_dev, epd->bEndpointAddress);
 retry:
-	result = usb_bulk_msg(i2400mu->usb_dev, pipe, buf, buf_size, &len, HZ);
+	result = usb_bulk_msg(i2400mu->usb_dev, pipe, buf, buf_size, &len, 200);
 	switch (result) {
 	case 0:
 		if (len != buf_size) {
diff --git a/drivers/net/wimax/i2400m/usb-rx.c b/drivers/net/wimax/i2400m/usb-rx.c
index 245587f..22d127b 100644
--- a/drivers/net/wimax/i2400m/usb-rx.c
+++ b/drivers/net/wimax/i2400m/usb-rx.c
@@ -214,7 +214,7 @@ retry:
 	}
 	result = usb_bulk_msg(
 		i2400mu->usb_dev, usb_pipe, rx_skb->data + rx_skb->len,
-		rx_size, &read_size, HZ);
+		rx_size, &read_size, 200);
 	usb_mark_last_busy(i2400mu->usb_dev);
 	switch (result) {
 	case 0:
diff --git a/drivers/net/wimax/i2400m/usb-tx.c b/drivers/net/wimax/i2400m/usb-tx.c
index a3c46e9..6cdf003 100644
--- a/drivers/net/wimax/i2400m/usb-tx.c
+++ b/drivers/net/wimax/i2400m/usb-tx.c
@@ -105,7 +105,7 @@ int i2400mu_tx(struct i2400mu *i2400mu, struct i2400m_msg_hdr *tx_msg,
 	usb_pipe = usb_sndbulkpipe(i2400mu->usb_dev, epd->bEndpointAddress);
 retry:
 	result = usb_bulk_msg(i2400mu->usb_dev, usb_pipe,
-			      tx_msg, tx_msg_size, &sent_size, HZ);
+			      tx_msg, tx_msg_size, &sent_size, 200);
 	usb_mark_last_busy(i2400mu->usb_dev);
 	switch (result) {
 	case 0:
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 5e07940..34df090 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -173,7 +173,7 @@ int __i2400mu_send_barker(struct i2400mu *i2400mu,
 	pipe = usb_sndbulkpipe(i2400mu->usb_dev, epd->bEndpointAddress);
 	memcpy(buffer, barker, barker_size);
 	ret = usb_bulk_msg(i2400mu->usb_dev, pipe, buffer, barker_size,
-			   &actual_len, HZ);
+			   &actual_len, 200);
 	if (ret < 0) {
 		if (ret != -EINVAL)
 			dev_err(dev, "E: barker error: %d\n", ret);
-- 
1.6.2.5

