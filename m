From: Bhaskar Jupudi <njupudi@ucsc.edu>
Subject: [PATCH] drivers : Remove unnecessary void pointer conversions
Date: Sat, 26 Mar 2016 20:42:20 -0700
Message-ID: <1459050140-14621-1-git-send-email-njupudi@ucsc.edu>
Cc: Bhaskar Jupudi <njupudi@ucsc.edu>
To: davem@davemloft.net, igal.liberman@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34718 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733AbcC0Dmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 23:42:44 -0400
Received: by mail-pf0-f180.google.com with SMTP id x3so111093429pfb.1
        for <netdev@vger.kernel.org>; Sat, 26 Mar 2016 20:42:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Explicit void pointer conversion is unnecessary
because the conversions to and from a void pointer
are always implicit in 'C'. Changed two instances 
of such conversions.


Signed-off-by: Bhaskar Jupudi <njupudi@ucsc.edu>
---
This patch is based on Kernel Janitors To-Do list

 drivers/net/ethernet/freescale/fman/fman.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index 623aa1c..8719f7b 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -2668,7 +2668,7 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 
 	fm_node = of_node_get(of_dev->dev.of_node);
 
-	u32_prop = (const u32 *)of_get_property(fm_node, "cell-index", &lenp);
+	u32_prop = of_get_property(fm_node, "cell-index", &lenp);
 	if (!u32_prop) {
 		dev_err(&of_dev->dev, "%s: of_get_property(%s, cell-index) failed\n",
 			__func__, fm_node->full_name);
@@ -2724,7 +2724,7 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 	/* Rounding to MHz */
 	fman->dts_params.clk_freq = DIV_ROUND_UP(clk_rate, 1000000);
 
-	u32_prop = (const u32 *)of_get_property(fm_node,
+	u32_prop = of_get_property(fm_node,
 						"fsl,qman-channel-range",
 						&lenp);
 	if (!u32_prop) {
-- 
2.5.0
