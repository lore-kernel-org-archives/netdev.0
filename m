From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 02/12] net: dsa: b53: Make b53_enable_cpu_port() take a port argument
Date: Tue, 19 Sep 2017 10:46:44 -0700
Message-ID: <20170919174654.2122-3-f.fainelli@gmail.com>
References: <20170919174654.2122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33068 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751778AbdISRrJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:47:09 -0400
Received: by mail-wr0-f196.google.com with SMTP id b9so192236wra.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:47:08 -0700 (PDT)
In-Reply-To: <20170919174654.2122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for future changes allowing the configuring of multiple
CPU ports, make b53_enable_cpu_port() take a port argument.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 274f3679f33d..d8bc54cfcfbe 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -538,19 +538,18 @@ static void b53_disable_port(struct dsa_switch *ds, int port,
 	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), reg);
 }
 
-static void b53_enable_cpu_port(struct b53_device *dev)
+static void b53_enable_cpu_port(struct b53_device *dev, int port)
 {
-	unsigned int cpu_port = dev->cpu_port;
 	u8 port_ctrl;
 
 	/* BCM5325 CPU port is at 8 */
-	if ((is5325(dev) || is5365(dev)) && cpu_port == B53_CPU_PORT_25)
-		cpu_port = B53_CPU_PORT;
+	if ((is5325(dev) || is5365(dev)) && port == B53_CPU_PORT_25)
+		port = B53_CPU_PORT;
 
 	port_ctrl = PORT_CTRL_RX_BCST_EN |
 		    PORT_CTRL_RX_MCST_EN |
 		    PORT_CTRL_RX_UCST_EN;
-	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(cpu_port), port_ctrl);
+	b53_write8(dev, B53_CTRL_PAGE, B53_PORT_CTRL(port), port_ctrl);
 }
 
 static void b53_enable_mib(struct b53_device *dev)
@@ -820,7 +819,7 @@ static int b53_setup(struct dsa_switch *ds)
 		if (BIT(port) & ds->enabled_port_mask)
 			b53_enable_port(ds, port, NULL);
 		else if (dsa_is_cpu_port(ds, port))
-			b53_enable_cpu_port(dev);
+			b53_enable_cpu_port(dev, port);
 		else
 			b53_disable_port(ds, port, NULL);
 	}
-- 
2.9.3
