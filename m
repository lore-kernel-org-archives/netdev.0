From: Stefan Eichenberger <eichest@gmail.com>
Subject: [PATCH v2] net: dsa: mv88e6xxx: forward unknown mc packets on mv88e6097
Date: Wed, 23 Nov 2016 17:54:40 +0100
Message-ID: <20161123165440.4894-1-stefan.eichenberger@netmodule.com>
References: <20161123165022.GD12698@gruene.netmodule.intranet>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33540 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755059AbcKWQzd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 11:55:33 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so2549900wmu.0
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 08:55:33 -0800 (PST)
In-Reply-To: <20161123165022.GD12698@gruene.netmodule.intranet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets with unknown destination addresses are not forwarded to the cpu
port on mv88e6097 based switches (e.g. MV88E6097) at the moment. This
commit enables PORT_CONTROL_FORWARD_UNKNOWN_MC for this family.

Signed-off-by: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b14b3d5..4d21086 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2487,6 +2487,10 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 		else
 			reg |= PORT_CONTROL_DSA_TAG;
+
+		if (mv88e6xxx_6097_family(chip))
+			reg |= PORT_CONTROL_FORWARD_UNKNOWN_MC;
+
 		reg |= PORT_CONTROL_EGRESS_ADD_TAG |
 			PORT_CONTROL_FORWARD_UNKNOWN;
 	}
-- 
2.9.3
