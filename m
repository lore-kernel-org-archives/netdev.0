From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 rfc 6/8] net: dsa: switch: Don't add CPU port to an mdb by default
Date: Wed,  6 Sep 2017 01:35:08 +0200
Message-ID: <1504654510-31004-7-git-send-email-andrew@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58235 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753652AbdIEXi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 19:38:59 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the host indicates when a multicast group should be forwarded
from the switch to the host, don't do it by default.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/switch.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/switch.c b/net/dsa/switch.c
index 326680039c52..147295d8de94 100644
--- a/net/dsa/switch.c
+++ b/net/dsa/switch.c
@@ -145,7 +145,7 @@ static int dsa_switch_mdb_add(struct dsa_switch *ds,
 	if (ds->index == info->sw_index)
 		set_bit(info->port, group);
 	for (port = 0; port < ds->num_ports; port++)
-		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
+		if (dsa_is_dsa_port(ds, port))
 			set_bit(port, group);
 
 	return dsa_switch_mdb_add_bitmap(ds, info, mdb, group);
-- 
2.14.1
