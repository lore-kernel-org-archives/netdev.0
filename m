From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 12/12] wimax/i2400m: fix inverted value in i2400ms_bus_setup()
Date: Wed,  4 Nov 2009 13:40:17 -0800
Message-ID: <e7fec0bbf13b9bc2869a18e66f0cda7bb7f559f0.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28863 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932785AbZKDVmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:21 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix inverted setting of 'retries'; when we are in the probe() path, we
should retry to enable the function only once; otherwise until it
times out.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index b06d526..76a50ac 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -183,9 +183,9 @@ int i2400ms_bus_setup(struct i2400m *i2400m)
 	}
 
 	if (i2400ms->iwmc3200 && i2400ms->debugfs_dentry == NULL)
-		retries = 0;
-	else
 		retries = 1;
+	else
+		retries = 0;
 	result = i2400ms_enable_function(i2400ms, retries);
 	if (result < 0) {
 		dev_err(dev, "Cannot enable SDIO function: %d\n", result);
-- 
1.6.2.5

