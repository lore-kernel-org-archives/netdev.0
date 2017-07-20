From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 13/13] net: dsa: lan9303: lan9303_port_mdb_del remove port 0
Date: Thu, 20 Jul 2017 15:57:28 +0200
Message-ID: <3bf6b19359cc40939b2e075635ed55d2@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Workaround for dsa_switch_mdb_add adding CPU port to group,
but forgetting to remove it:

Remove port 0 if only port 0 is only port left.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 drivers/net/dsa/lan9303-core.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 54646eb38185..61c915eed649 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -1424,6 +1424,17 @@ static int lan9303_port_mdb_del(
 	if (mdb->vid)
 		return -EOPNOTSUPP;
 	lan9303_alr_del_port(chip, mdb->addr, port);
+
+	{
+		/* Workaround for dsa_switch_mdb_add adding CPU port to
+		 * group, but forgetting to remove it. Remove port 0
+		 * if only port left
+		 **/
+		struct lan9303_alr_cache_entry *entr =
+			lan9303_alr_cache_find_mac(chip, mdb->addr);
+		if (entr && (entr->port_map == BIT(0)))
+			lan9303_alr_del_port(chip, mdb->addr, 0);
+	}
 	return 0;
 }
 
-- 
2.11.0


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
