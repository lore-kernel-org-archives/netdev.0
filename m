From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 03/18] net: dsa: mv88e6xxx: Disable Message Port bit for CPU port
Date: Sat, 21 Mar 2015 08:46:40 -0700
Message-ID: <1426952815-4642-4-git-send-email-linux@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Datasheet says that the Message Port bit should not be set for the CPU port.
Having it set causes DSA tagged packets to be sent to the CPU port roughly
every 30 seconds. Those packets are the same as real packets forwarded between
switch ports if the switch is configured for switching between multiple ports.
The packets are then bridged by the software bridge, resulting in duplicated
packets on the network.

Reported-by: Andrew Lunn <andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 3c2cb45..d4447b7 100644
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
