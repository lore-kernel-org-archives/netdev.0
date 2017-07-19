From: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <mnhu@prevas.dk>
Subject: [PATCH] net: dsa: mv88e6xxx: Enable CMODE config support for 6390X
Date: Wed, 19 Jul 2017 08:17:02 +0200
Message-ID: <20170719061702.7692-1-mnhu@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <mnhu@prevas.dk>,
        <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.prevas.se ([62.95.78.3]:56283 "EHLO mail01.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752794AbdGSG10 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 02:27:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f39908d3b1c45 ('net: dsa: mv88e6xxx: Set the CMODE for mv88e6390
ports 9 & 10') added support for setting the CMODE for the 6390X family,
but only enabled it for 9290 and 6390 - and left out 6390X.

Fix support for setting the CMODE on 6390X also by assigning
mv88e6390x_port_set_cmode() to the .port_set_cmode function pointer in
mv88e6390x_ops too.

Signed-off-by: Martin Hundebøll <mnhu@prevas.dk>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 947ea352a57a..7fa19d4a8e13 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3233,6 +3233,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_jumbo_size = mv88e6165_port_set_jumbo_size,
 	.port_egress_rate_limiting = mv88e6097_port_egress_rate_limiting,
 	.port_pause_limit = mv88e6390_port_pause_limit,
+	.port_set_cmode = mv88e6390x_port_set_cmode,
 	.port_disable_learn_limit = mv88e6xxx_port_disable_learn_limit,
 	.port_disable_pri_override = mv88e6xxx_port_disable_pri_override,
 	.stats_snapshot = mv88e6390_g1_stats_snapshot,
-- 
2.13.3
