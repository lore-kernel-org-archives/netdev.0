From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net 1/3] net: dsa: mv88e6xxx: unlock DSA and CPU ports
Date: Thu, 14 Apr 2016 14:42:07 -0400
Message-ID: <1460659329-11473-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460659329-11473-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460659329-11473-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Locking a port generates an hardware interrupt when a new SA address is
received. This enables CPU directed learning, which is needed for 802.1X
MAC authentication.

To disable automatic learning on a port, the only configuration needed
is to set its Port Association Vector to all zero.

Clear PAV when SA learning should be disabled instead of locking a port.

Fixes: 4c7ea3c0791e ("net: dsa: mv88e6xxx: disable SA learning for DSA and CPU ports")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9985a0c..7725e29 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2544,7 +2544,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	reg = 1 << port;
 	/* Disable learning for DSA and CPU ports */
 	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
-		reg = PORT_ASSOC_VECTOR_LOCKED_PORT;
+		reg = 0;
 
 	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
 	if (ret)
-- 
2.8.0
