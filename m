From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: fix 6185 hardware bridging
Date: Fri, 25 Mar 2016 13:01:59 -0400
Message-ID: <1458925319-16771-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51003 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbcCYREL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 13:04:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 88E6185 switch also has a MapDA bit in its Port Control 2 register.
When this bit is cleared, all frames are sent out to the CPU port.

Set this bit to rely on ATU hits and direct the frame out of the correct
ports, and thus enable hardware bridging.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4332b15..85ed3e2 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2586,7 +2586,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	reg = 0;
 	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
 	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6320_family(ds))
+	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6320_family(ds) ||
+	    mv88e6xxx_6185_family(ds))
 		reg = PORT_CONTROL_2_MAP_DA;
 
 	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-- 
2.7.4
