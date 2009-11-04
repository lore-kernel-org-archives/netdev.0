From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 11/12] wimax/iwmc3200: don't disable the SDIO function if enable fails
Date: Wed,  4 Nov 2009 13:39:47 -0800
Message-ID: <5c29e21d4768a7f1ce46f622b379802edeb1daf3.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:64800 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758261AbZKDVlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:51 -0500
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

In the iwmc3200, disabling the WiMAX SDIO function when enable fails
would possibly result in a device reset triggered by the iwmc3200's
top controller since it monitors the bus reset activities from each
SDIO function. In any case, the disable makes no sense; if the enable
fails, it should not be disabled.

Thus we remove the unecessary sdio_disable_func() in
i2400ms_enable_function().

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 0d64d16..9d6046f 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -130,7 +130,6 @@ int i2400ms_enable_function(struct sdio_func *func)
 			goto function_enabled;
 		}
 		d_printf(2, dev, "SDIO function failed to enable: %d\n", err);
-		sdio_disable_func(func);
 		sdio_release_host(func);
 		msleep(I2400MS_INIT_SLEEP_INTERVAL);
 	}
-- 
1.6.2.5

