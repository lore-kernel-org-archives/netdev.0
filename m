From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/3] net: dsa: b53: Fix CPU port for 58xx devices
Date: Mon, 24 Apr 2017 14:27:23 -0700
Message-ID: <20170424212723.15407-4-f.fainelli@gmail.com>
References: <20170424212723.15407-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoifairelinux.com,
        eric@anholt.net, jon.mason@broadcom.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36233 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S978277AbdDXV1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 17:27:37 -0400
Received: by mail-wr0-f196.google.com with SMTP id v42so14296309wrc.3
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 14:27:36 -0700 (PDT)
In-Reply-To: <20170424212723.15407-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 58xx devices (Northstar Plus) do actually have their CPU port wired
at port 8, it was unfortunately set to port 5 (B53_CPU_PORT_25) which is
incorrect, since that is the second possible management port.

Fixes: 991a36bb4645 ("net: dsa: b53: Add support for BCM585xx/586xx/88312 integrated switch")
Reported-by: Eric Anholt <eric@anholt.net>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index b66ee18cbe49..fa0eece21eef 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1764,7 +1764,7 @@ static const struct b53_chip_data b53_switch_chips[] = {
 		.vlans	= 4096,
 		.enabled_ports = 0x1ff,
 		.arl_entries = 4,
-		.cpu_port = B53_CPU_PORT_25,
+		.cpu_port = B53_CPU_PORT,
 		.vta_regs = B53_VTA_REGS,
 		.duplex_reg = B53_DUPLEX_STAT_GE,
 		.jumbo_pm_reg = B53_JUMBO_PORT_MASK,
-- 
2.9.3
