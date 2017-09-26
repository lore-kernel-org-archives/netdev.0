From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 4/6] net: dsa: mv88e6xxx: Print offending port when vlan check fails
Date: Wed, 27 Sep 2017 00:26:01 +0200
Message-ID: <1506464764-12699-5-git-send-email-andrew@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:57006 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967343AbdIZW0l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 18:26:41 -0400
In-Reply-To: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When testing if a VLAN is one more than one bridge, we print an error
message that the VLAN is already in use somewhere else. Print both the
new port which would like the VLAN, and the port which already has it,
to aid debugging.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 884f0507cf48..8a4756490a5a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1134,8 +1134,8 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			if (!ds->ports[i].bridge_dev)
 				continue;
 
-			dev_err(ds->dev, "p%d: hw VLAN %d already used by %s\n",
-				port, vlan.vid,
+			dev_err(ds->dev, "p%d: hw VLAN %d already used by port %d in %s\n",
+				port, vlan.vid, i,
 				netdev_name(ds->ports[i].bridge_dev));
 			err = -EOPNOTSUPP;
 			goto unlock;
-- 
2.14.1
