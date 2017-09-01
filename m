From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: dsa: bcm_sf2: Advertise number of egress queues
Date: Fri,  1 Sep 2017 16:59:13 -0700
Message-ID: <1504310354-42773-4-git-send-email-f.fainelli@gmail.com>
References: <1504310354-42773-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35978 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752329AbdIBAFZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 20:05:25 -0400
Received: by mail-qk0-f195.google.com with SMTP id l65so1210257qkc.3
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 17:05:24 -0700 (PDT)
In-Reply-To: <1504310354-42773-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch supports 8 egress queues per port, so indicate that such that
net/dsa/slave.c::dsa_slave_create can allocate the right number of TX
queues.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 8492c9d64004..3f1ad9d5d7c5 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1147,6 +1147,9 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	ds = dev->ds;
 	ds->ops = &bcm_sf2_ops;
 
+	/* Advertise the 8 egress queues */
+	ds->num_tx_queues = 8;
+
 	dev_set_drvdata(&pdev->dev, priv);
 
 	spin_lock_init(&priv->indir_lock);
-- 
1.9.1
