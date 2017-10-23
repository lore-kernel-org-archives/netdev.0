From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: check master device before put
Date: Mon, 23 Oct 2017 14:01:41 -0400
Message-ID: <20171023180141.3674-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49722 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751735AbdJWSBp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:01:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case of pdata, the dsa_cpu_parse function calls dev_put() before
making sure it isn't NULL. Fix this.

Fixes: 71e0bbde0d88 ("net: dsa: Add support for platform data")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 9e8b8aab049d..908c06e32520 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -489,14 +489,15 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 		if (!ethernet)
 			return -EINVAL;
 		ethernet_dev = of_find_net_device_by_node(ethernet);
+		if (!ethernet_dev)
+			return -EPROBE_DEFER;
 	} else {
 		ethernet_dev = dsa_dev_to_net_device(ds->cd->netdev[index]);
+		if (!ethernet_dev)
+			return -EPROBE_DEFER;
 		dev_put(ethernet_dev);
 	}
 
-	if (!ethernet_dev)
-		return -EPROBE_DEFER;
-
 	if (!dst->cpu_dp) {
 		dst->cpu_dp = port;
 		dst->cpu_dp->master = ethernet_dev;
-- 
2.14.2
