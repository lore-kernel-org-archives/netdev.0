From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 5/9] net: dsa: mv88e6352: disable mirroring
Date: Mon,  1 Jun 2015 21:27:46 -0400
Message-ID: <1433208470-25338-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"Scott Feldman" <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"Chris Healy" <cphealy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:51183 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754483AbbFBB2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 21:28:03 -0400
In-Reply-To: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable the mirroring policy in the monitor control register, since this
feature is not needed.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c | 10 +++-------
 drivers/net/dsa/mv88e6xxx.h |  1 +
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 838494a..f541362 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -63,13 +63,9 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL,
 		  GLOBAL_CONTROL_PPU_ENABLE | GLOBAL_CONTROL_DISCARD_EXCESS);
 
-	/* Configure the upstream port, and configure the upstream
-	 * port as the port to which ingress and egress monitor frames
-	 * are to be sent.
-	 */
-	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
+	/* Configure the upstream port, and disable policy mirroring. */
+	reg = upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT |
+		GLOBAL_MONITOR_CONTROL_MIRROR_DISABLED;
 	REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
 
 	/* Disable remote management for now, and set the switch's
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 42032c3..f4ea66a 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -237,6 +237,7 @@
 #define GLOBAL_MONITOR_CONTROL_ARP_SHIFT	4
 #define GLOBAL_MONITOR_CONTROL_MIRROR_SHIFT	0
 #define GLOBAL_MONITOR_CONTROL_ARP_DISABLED	(0xf0)
+#define GLOBAL_MONITOR_CONTROL_MIRROR_DISABLED	0x0f
 #define GLOBAL_CONTROL_2	0x1c
 #define GLOBAL_CONTROL_2_NO_CASCADE		0xe000
 #define GLOBAL_CONTROL_2_MULTIPLE_CASCADE	0xf000
-- 
2.4.1
