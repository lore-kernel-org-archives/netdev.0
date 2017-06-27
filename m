From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH net-next 3/3] net: ethernet: ti: netcp_ethss: use cpts to check if packet needs timestamping
Date: Tue, 27 Jun 2017 16:58:53 +0300
Message-ID: <1498571933-3663-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1498571933-3663-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: m-karicheri2@ti.com, w-kwok2@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:32951 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751526AbdF0N7D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 09:59:03 -0400
Received: by mail-lf0-f52.google.com with SMTP id m77so17711007lfe.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 06:59:02 -0700 (PDT)
In-Reply-To: <1498571933-3663-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is cpts function to check if packet can be timstamped with cpts.
Seems that ptp_classify_raw cover all cases listed with "case".

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 0847a8f..28cb38a 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2503,24 +2503,8 @@ static bool gbe_need_txtstamp(struct gbe_intf *gbe_intf,
 			      const struct netcp_packet *p_info)
 {
 	struct sk_buff *skb = p_info->skb;
-	unsigned int class = ptp_classify_raw(skb);
 
-	if (class == PTP_CLASS_NONE)
-		return false;
-
-	switch (class) {
-	case PTP_CLASS_V1_IPV4:
-	case PTP_CLASS_V1_IPV6:
-	case PTP_CLASS_V2_IPV4:
-	case PTP_CLASS_V2_IPV6:
-	case PTP_CLASS_V2_L2:
-	case (PTP_CLASS_V2_VLAN | PTP_CLASS_L2):
-	case (PTP_CLASS_V2_VLAN | PTP_CLASS_IPV4):
-	case (PTP_CLASS_V2_VLAN | PTP_CLASS_IPV6):
-		return true;
-	}
-
-	return false;
+	return cpts_can_timestamp(gbe_intf->gbe_dev->cpts, skb);
 }
 
 static int gbe_txtstamp_mark_pkt(struct gbe_intf *gbe_intf,
-- 
2.7.4
