From: Andrew Schwartzmeyer <andschwa@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Fix dereference of nvdev before check
Date: Tue, 18 Aug 2015 20:06:32 -0700
Message-ID: <1439953592-8210-1-git-send-email-andschwa@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haiyangz@microsoft.com>, <andschwa@microsoft.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0119.outbound.protection.outlook.com ([65.55.169.119]:41517
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751797AbbHSDGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 23:06:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Passes static analysis by Smatch.

Signed-off-by: Andrew Schwartzmeyer <andschwa@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f3b9d3eb753b..2990024b90f9 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -777,14 +777,17 @@ static int netvsc_set_channels(struct net_device *net,
 	struct hv_device *dev = net_device_ctx->device_ctx;
 	struct netvsc_device *nvdev = hv_get_drvdata(dev);
 	struct netvsc_device_info device_info;
-	const u32 num_chn = nvdev->num_chn;
-	const u32 max_chn = min_t(u32, nvdev->max_chn, num_online_cpus());
+	u32 num_chn;
+	u32 max_chn;
 	int ret = 0;
 	bool recovering = false;
 
 	if (!nvdev || nvdev->destroy)
 		return -ENODEV;
 
+	num_chn = nvdev->num_chn;
+	max_chn = min_t(u32, nvdev->max_chn, num_online_cpus());
+
 	if (nvdev->nvsp_version < NVSP_PROTOCOL_VERSION_5) {
 		pr_info("vRSS unsupported before NVSP Version 5\n");
 		return -EINVAL;
-- 
2.5.0
