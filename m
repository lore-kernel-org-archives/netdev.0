From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 18/21] wimax/i2400m: when bootstrap fails, reinitialize the bootrom
Date: Thu, 11 Jun 2009 14:35:55 -0700
Message-ID: <8b5b30ee7ddc989b59ce05dcf2d024a819dc8040.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27879 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756285AbZFKVgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:50 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

When a device reset happens during firmware load [in
i2400m_dev_bootstrap()], __i2400m_dev_start() will retry a number of
times. However, for those retries to be able to accomplish anything,
the device's bootrom has to be reinitialized.

Thus, on the retry path, pass the I2400M_MAC_REINIT to the firmware
load code.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 8d8628e..2a093c5 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -454,7 +454,7 @@ error_rx_setup:
 error_tx_setup:
 error_bootstrap:
 	if (result == -ERESTARTSYS && times-- > 0) {
-		flags = I2400M_BRI_SOFT;
+		flags = I2400M_BRI_SOFT|I2400M_BRI_MAC_REINIT;
 		goto retry;
 	}
 	d_fnend(3, dev, "(net_dev %p [i2400m %p]) = %d\n",
-- 
1.6.2.3

