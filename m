From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 03/16] net: dsa: mv88e6xxx: Disable Message Port bit for CPU port
Date: Thu, 26 Mar 2015 18:36:30 -0700
Message-ID: <1427420203-27685-4-git-send-email-linux@roeck-us.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39316 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbbC0Bg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 21:36:56 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YbJCh-0020XJ-Fn
	for netdev@vger.kernel.org; Fri, 27 Mar 2015 01:36:55 +0000
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Datasheet says that the Message Port bit should not be set for the CPU port.
Having it set causes DSA tagged packets to be sent to the CPU port roughly
every 30 seconds. Those packets are the same as real packets forwarded between
switch ports if the switch is configured for switching between multiple ports.
The packets are then bridged by the software bridge, resulting in duplicated
packets on the network.

Reported-by: Andrew Lunn <andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 2052e51edd5d..5da50b00fdf6 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -707,11 +707,10 @@ int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
 
 	mutex_lock(&ps->smi_mutex);
 
-	/* Port Control 1: disable trunking.  Also, if this is the
-	 * CPU port, enable learn messages to be sent to this port.
+	/* Port Control 1: disable trunking, disable sending
+	 * learning messages to this port.
 	 */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x05,
-				   dsa_is_cpu_port(ds, port) ? 0x8000 : 0x0000);
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x05, 0x0000);
 	if (ret)
 		goto abort;
 
-- 
2.1.0
