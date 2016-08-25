From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next-v2 2/6] net: dsa: b53: Prepare to support 7445 switch
Date: Thu, 25 Aug 2016 09:24:38 -0700
Message-ID: <1472142282-1479-4-git-send-email-f.fainelli@gmail.com>
References: <1472142282-1479-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jonas.gorski@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33095 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759585AbcHYQZA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:25:00 -0400
Received: by mail-pa0-f68.google.com with SMTP id vy10so3348659pac.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:24:59 -0700 (PDT)
In-Reply-To: <1472142282-1479-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate a device entry for the Broadcom BCM7445 integrated switch
currently backed by bcm_sf2.c. Since this is the latest generation, it
has 4 ARL entries, 4K VLANs and uses Port 8 for the CPU/IMP port.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 12 ++++++++++++
 drivers/net/dsa/b53/b53_priv.h   |  1 +
 2 files changed, 13 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 9fc726592071..d014c918ebfd 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1598,6 +1598,18 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
 		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
 	},
+	{
+		.chip_id = BCM7445_DEVICE_ID,
+		.dev_name = "BCM7445",
+		.vlans	= 4096,
+		.enabled_ports = 0x1ff,
+		.arl_entries = 4,
+		.cpu_port = B53_CPU_PORT,
+		.vta_regs = B53_VTA_REGS,
+		.duplex_reg = B53_DUPLEX_STAT_GE,
+		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
+		.jumbo_size_reg = B53_JUMBO_MAX_SIZE,
+	},
 };
 
 static int b53_switch_init(struct b53_device *dev)
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index d268493a5fec..cf2ff2cbc8ab 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -60,6 +60,7 @@ enum {
 	BCM53018_DEVICE_ID = 0x53018,
 	BCM53019_DEVICE_ID = 0x53019,
 	BCM58XX_DEVICE_ID = 0x5800,
+	BCM7445_DEVICE_ID = 0x7445,
 };
 
 #define B53_N_PORTS	9
-- 
2.7.4
