From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2] net: systemport: Fix software statistics for SYSTEMPORT Lite
Date: Tue,  8 Aug 2017 14:45:09 -0700
Message-ID: <20170808214509.26252-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33975 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752464AbdHHVpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 17:45:13 -0400
Received: by mail-qt0-f195.google.com with SMTP id i19so4262820qte.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 14:45:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With SYSTEMPORT Lite we have holes in our statistics layout that make us
skip over the hardware MIB counters, bcm_sysport_get_stats() was not
taking that into account resulting in reporting 0 for all SW-maintained
statistics, fix this by skipping accordingly.

Fixes: 44a4524c54af ("net: systemport: Add support for SYSTEMPORT Lite")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:

- no debugging

 drivers/net/ethernet/broadcom/bcmsysport.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 5333601f855f..dc3052751bc1 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -449,6 +449,10 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 			p = (char *)&dev->stats;
 		else
 			p = (char *)priv;
+
+		if (priv->is_lite && !bcm_sysport_lite_stat_valid(s->type))
+			continue;
+
 		p += s->stat_offset;
 		data[j] = *(unsigned long *)p;
 		j++;
-- 
2.9.3
