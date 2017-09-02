From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/4] net: dsa: bcm_sf2: Advertise number of egress queues
Date: Sat,  2 Sep 2017 11:06:08 -0700
Message-ID: <20170902180609.23122-4-f.fainelli@gmail.com>
References: <20170902180609.23122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34794 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752723AbdIBSGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 14:06:20 -0400
Received: by mail-oi0-f68.google.com with SMTP id w10so2405202oie.1
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 11:06:20 -0700 (PDT)
In-Reply-To: <20170902180609.23122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch supports 8 egress queues per port, so indicate that such that
net/dsa/slave.c::dsa_slave_create can allocate the right number of TX queues.
While at it use SF2_NUM_EGRESS_QUEUE as a define for the number of queues we
support.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 5 ++++-
 drivers/net/dsa/bcm_sf2_regs.h | 3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 554fe2df9365..6b184bafa235 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -244,7 +244,7 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	 * to a different queue number
 	 */
 	reg = core_readl(priv, CORE_PORT_TC2_QOS_MAP_PORT(port));
-	for (i = 0; i < 8; i++)
+	for (i = 0; i < SF2_NUM_EGRESS_QUEUES; i++)
 		reg |= i << (PRT_TO_QID_SHIFT * i);
 	core_writel(priv, reg, CORE_PORT_TC2_QOS_MAP_PORT(port));
 
@@ -1151,6 +1151,9 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	ds = dev->ds;
 	ds->ops = &bcm_sf2_ops;
 
+	/* Advertise the 8 egress queues */
+	ds->num_tx_queues = SF2_NUM_EGRESS_QUEUES;
+
 	dev_set_drvdata(&pdev->dev, priv);
 
 	spin_lock_init(&priv->indir_lock);
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 26052450091e..49695fcc2ea8 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -401,4 +401,7 @@ enum bcm_sf2_reg_offs {
 
 #define CFP_NUM_RULES			256
 
+/* Number of egress queues per port */
+#define SF2_NUM_EGRESS_QUEUES		8
+
 #endif /* __BCM_SF2_REGS_H */
-- 
2.11.0
