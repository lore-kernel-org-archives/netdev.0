From: Li Fei <fei.li@intel.com>
Subject: [PATCH 3/5] wl1251: call pm_runtime_put_sync in
 pm_runtime_get_sync failed case
Date: Thu, 28 Feb 2013 15:51:32 +0800
Message-ID: <1362037892.6212.13.camel@fli24-HP-Compaq-8100-Elite-CMT-PC>
References: <1362037031.6212.3.camel@fli24-HP-Compaq-8100-Elite-CMT-PC>
	 <1362037455.6212.8.camel@fli24-HP-Compaq-8100-Elite-CMT-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, fei.li@intel.com
To: coelho@ti.com, linville@tuxdriver.com, wfp5p@virginia.edu,
	gregkh@linuxfoundation.org, notasas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59124 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958Ab3B1HxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 02:53:06 -0500
In-Reply-To: <1362037455.6212.8.camel@fli24-HP-Compaq-8100-Elite-CMT-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Even in failed case of pm_runtime_get_sync, the usage_count
is incremented. In order to keep the usage_count with correct
value and runtime power management to behave correctly, call
pm_runtime_put(_sync) in such case.

Signed-off-by Liu Chuansheng <chuansheng.liu@intel.com>
Signed-off-by: Li Fei <fei.li@intel.com>
---
 drivers/net/wireless/ti/wl1251/sdio.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/ti/wl1251/sdio.c
index e57ee48..e2b3d9c 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -186,8 +186,10 @@ static int wl1251_sdio_set_power(struct wl1251 *wl, bool enable)
 			wl->set_power(true);
 
 		ret = pm_runtime_get_sync(&func->dev);
-		if (ret < 0)
+		if (ret < 0) {
+			pm_runtime_put_sync(&func->dev);
 			goto out;
+		}
 
 		sdio_claim_host(func);
 		sdio_enable_func(func);
-- 
1.7.4.1
