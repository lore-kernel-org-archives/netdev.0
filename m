From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next-v2 1/6] net: dsa: b53: Initialize ds->ops in b53_switch_alloc
Date: Thu, 25 Aug 2016 09:24:37 -0700
Message-ID: <1472142282-1479-3-git-send-email-f.fainelli@gmail.com>
References: <1472142282-1479-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jonas.gorski@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34526 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759803AbcHYQY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:24:58 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so3488976pfb.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:24:58 -0700 (PDT)
In-Reply-To: <1472142282-1479-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to allow drivers to override specific dsa_switch_driver
callbacks, initialize ds->ops to b53_switch_ops earlier, which avoids
having to expose this structure to glue drivers.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 6fb77cca78bb..9fc726592071 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1602,7 +1602,6 @@ static const struct b53_chip_data b53_switch_chips[] = {
 
 static int b53_switch_init(struct b53_device *dev)
 {
-	struct dsa_switch *ds = dev->ds;
 	unsigned int i;
 	int ret;
 
@@ -1618,7 +1617,6 @@ static int b53_switch_init(struct b53_device *dev)
 			dev->vta_regs[1] = chip->vta_regs[1];
 			dev->vta_regs[2] = chip->vta_regs[2];
 			dev->jumbo_pm_reg = chip->jumbo_pm_reg;
-			ds->ops = &b53_switch_ops;
 			dev->cpu_port = chip->cpu_port;
 			dev->num_vlans = chip->vlans;
 			dev->num_arl_entries = chip->arl_entries;
@@ -1706,6 +1704,7 @@ struct b53_device *b53_switch_alloc(struct device *base,
 	dev->ds = ds;
 	dev->priv = priv;
 	dev->ops = ops;
+	ds->ops = &b53_switch_ops;
 	mutex_init(&dev->reg_mutex);
 	mutex_init(&dev->stats_mutex);
 
-- 
2.7.4
