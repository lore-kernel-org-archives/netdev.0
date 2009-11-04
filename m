From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 07/13] wimax/i2400m: don't overwrite error codes when failing to load firmware
Date: Wed,  4 Nov 2009 13:39:58 -0800
Message-ID: <cb5b756f746b77c5323ae413a41e9a40ea33c453.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20718 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932736AbZKDVmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:08 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure that i2400m_dev_bootstrap() doesn't overwrite the last known
error code with -ENOENT; when a firmware fails to load, we want to
know the cause and not a generic error code.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 69f9e45..3d67bcf 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -1573,7 +1573,6 @@ int i2400m_dev_bootstrap(struct i2400m *i2400m, enum i2400m_bri flags)
 		fw_name = i2400m->bus_fw_names[itr];
 		if (fw_name == NULL) {
 			dev_err(dev, "Could not find a usable firmware image\n");
-			ret = -ENOENT;
 			break;
 		}
 		d_printf(1, dev, "trying firmware %s (%d)\n", fw_name, itr);
-- 
1.6.2.5

