From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: fix 6085 frame mode masking
Date: Mon,  5 Jun 2017 18:17:16 -0400
Message-ID: <20170605221716.32235-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The register bits used for the frame mode were masked with DSA (0x1)
instead of the mask value (0x3) in the 6085 implementation of
port_set_frame_mode. Fix this.

Fixes: 56995cbc3540 ("net: dsa: mv88e6xxx: Refactor CPU and DSA port setup")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/port.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 360c77854f2a..3719ece60c61 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -451,7 +451,7 @@ int mv88e6085_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	reg &= ~PORT_CONTROL_FRAME_MODE_DSA;
+	reg &= ~PORT_CONTROL_FRAME_MASK;
 
 	switch (mode) {
 	case MV88E6XXX_FRAME_MODE_NORMAL:
-- 
2.13.0
