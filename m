From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v2 2/2] Altera TSE: Disable Multicast filtering to workaround problem
Date: Wed, 14 May 2014 14:38:37 -0500
Message-ID: <1400096317-4969-3-git-send-email-vbridgers2013@gmail.com>
References: <1400096317-4969-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42269 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbaENTm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:42:57 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so27332pab.19
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 12:42:57 -0700 (PDT)
In-Reply-To: <1400096317-4969-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch disables multicast hash filtering if present in the hardware
and uses promiscuous mode instead until the problem with multicast
filtering has been debugged, integrated and tested.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V2: - Create seperate patch from V1 for multicast filtering
      workaround
---
 drivers/net/ethernet/altera/altera_tse_main.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index ecc3b4e..7330681 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -1376,6 +1376,11 @@ static int altera_tse_probe(struct platform_device *pdev)
 		of_property_read_bool(pdev->dev.of_node,
 				      "altr,has-hash-multicast-filter");
 
+	/* Set hash filter to not set for now until the
+	 * multicast filter receive issue is debugged
+	 */
+	priv->hash_filter = 0;
+
 	/* get supplemental address settings for this instance */
 	priv->added_unicast =
 		of_property_read_bool(pdev->dev.of_node,
-- 
1.7.9.5
