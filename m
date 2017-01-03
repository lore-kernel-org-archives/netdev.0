From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/3] net: dsa: restore HWMON support in dsa2
Date: Tue,  3 Jan 2017 13:15:38 -0500
Message-ID: <20170103181538.2593-4-vivien.didelot@savoirfairelinux.com>
References: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45666 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965473AbdACSQI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 13:16:08 -0500
In-Reply-To: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HWMON support was only registered in the legacy DSA code. Register
it in the newer DSA code (dsa2) as well.
---
 net/dsa/dsa2.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 5fff951a0a49..668aa2974d01 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -348,6 +348,8 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 			continue;
 	}
 
+	dsa_hwmon_register(ds);
+
 	return 0;
 }
 
@@ -356,6 +358,8 @@ static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	struct device_node *port;
 	u32 index;
 
+	dsa_hwmon_unregister(ds);
+
 	for (index = 0; index < DSA_MAX_PORTS; index++) {
 		port = ds->ports[index].dn;
 		if (!port)
-- 
2.11.0
