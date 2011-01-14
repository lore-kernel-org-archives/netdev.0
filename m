From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH] ARM: mxs: pass fec device name via platform data
Date: Fri, 14 Jan 2011 14:53:20 +0800
Message-ID: <1294988000-20232-1-git-send-email-shawn.guo@freescale.com>
References: <20110113150622.GV24920@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shawn Guo <shawn.guo@freescale.com>
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<lw@karo-electronics.de>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:20006
	"EHLO VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753725Ab1ANGua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 01:50:30 -0500
In-Reply-To: <20110113150622.GV24920@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
 arch/arm/mach-mxs/devices/platform-fec.c        |   11 ++++++-----
 arch/arm/mach-mxs/include/mach/devices-common.h |    1 +
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mach-mxs/devices/platform-fec.c b/arch/arm/mach-mxs/devices/platform-fec.c
index c42dff7..75eb26b 100644
--- a/arch/arm/mach-mxs/devices/platform-fec.c
+++ b/arch/arm/mach-mxs/devices/platform-fec.c
@@ -10,20 +10,21 @@
 #include <mach/mx28.h>
 #include <mach/devices-common.h>
 
-#define mxs_fec_data_entry_single(soc, _id)				\
+#define mxs_fec_data_entry_single(soc, _devid, _id)			\
 	{								\
+		.devid = _devid,					\
 		.id = _id,						\
 		.iobase = soc ## _ENET_MAC ## _id ## _BASE_ADDR,	\
 		.irq = soc ## _INT_ENET_MAC ## _id,			\
 	}
 
-#define mxs_fec_data_entry(soc, _id)					\
-	[_id] = mxs_fec_data_entry_single(soc, _id)
+#define mxs_fec_data_entry(soc, _devid, _id)				\
+	[_id] = mxs_fec_data_entry_single(soc, _devid, _id)
 
 #ifdef CONFIG_SOC_IMX28
 const struct mxs_fec_data mx28_fec_data[] __initconst = {
 #define mx28_fec_data_entry(_id)					\
-	mxs_fec_data_entry(MX28, _id)
+	mxs_fec_data_entry(MX28, "imx28-fec", _id)
 	mx28_fec_data_entry(0),
 	mx28_fec_data_entry(1),
 };
@@ -45,6 +46,6 @@ struct platform_device *__init mxs_add_fec(
 		},
 	};
 
-	return mxs_add_platform_device("imx28-fec", data->id,
+	return mxs_add_platform_device(data->devid, data->id,
 			res, ARRAY_SIZE(res), pdata, sizeof(*pdata));
 }
diff --git a/arch/arm/mach-mxs/include/mach/devices-common.h b/arch/arm/mach-mxs/include/mach/devices-common.h
index 6c3d1a1..10fbcfd 100644
--- a/arch/arm/mach-mxs/include/mach/devices-common.h
+++ b/arch/arm/mach-mxs/include/mach/devices-common.h
@@ -33,6 +33,7 @@ int __init mxs_add_duart(const struct amba_device *dev);
 /* fec */
 #include <linux/fec.h>
 struct mxs_fec_data {
+	const char *devid;
 	int id;
 	resource_size_t iobase;
 	resource_size_t iosize;
-- 
1.7.1


