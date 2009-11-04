From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 12/12] wimax/iwmc3200: increase wait time before enable retry
Date: Wed,  4 Nov 2009 13:39:48 -0800
Message-ID: <8bec9a5efd5691c5a32d85da1da09643290ebb72.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:16607 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932633AbZKDVlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:51 -0500
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

When trying to enable the iwmc3200 WiMAX SDIO function, we loop
waiting for the top controller to be up and running (at which point we
can succesfully enable the function). Between each try we wait for
I2400MS_INIT_SLEEP_INTERVAL ms.

Integration tests have found the current value of 10ms to be too
short; it was upped to 100ms to give more time to the top controller
to be ready.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/i2400m-sdio.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-sdio.h b/drivers/net/wimax/i2400m/i2400m-sdio.h
index cfaedfa..18218a2 100644
--- a/drivers/net/wimax/i2400m/i2400m-sdio.h
+++ b/drivers/net/wimax/i2400m/i2400m-sdio.h
@@ -78,7 +78,7 @@ enum {
 	I2400MS_INTR_GET_SIZE_ADDR = 0x2C,
 	/* The number of ticks to wait for the device to signal that
 	 * it is ready */
-	I2400MS_INIT_SLEEP_INTERVAL = 10,
+	I2400MS_INIT_SLEEP_INTERVAL = 100,
 	/* How long to wait for the device to settle after reset */
 	I2400MS_SETTLE_TIME = 40,
 	/* The number of msec to wait for IOR after sending IOE */
-- 
1.6.2.5

