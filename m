From: Andrew Lunn <andrew@lunn.ch>
Subject: [patch net] net: dsa: mv88e6xxx: Allow dsa and cpu ports in multiple vlans
Date: Mon, 25 Sep 2017 23:32:20 +0200
Message-ID: <1506375140-2853-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:55229 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932698AbdIYVcs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 17:32:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ports with the same VLAN must all be in the same bridge. However the
CPU and DSA ports need to be in multiple VLANs spread over multiple
bridges. So exclude them when performing this test.

Fixes: b2f81d304cee ("net: dsa: add CPU and DSA ports as VLAN members")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c6678aa9b4ef..674dab71d71c 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1100,6 +1100,10 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 	};
 	int i, err;
 
+	/* DSA and CPU ports have to be members of multiple vlans */
+	if (dsa_is_dsa_port(ds, port) || dsa_is_cpu_port(ds, port))
+		return 0;
+
 	if (!vid_begin)
 		return -EOPNOTSUPP;
 
-- 
2.14.1
