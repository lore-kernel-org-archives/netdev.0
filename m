From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/7] net: dsa: check master device before put
Date: Fri, 27 Oct 2017 15:55:16 -0400
Message-ID: <20171027195519.5931-5-vivien.didelot@savoirfairelinux.com>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the case of pdata, the dsa_cpu_parse function calls dev_put() before
making sure it isn't NULL. Fix this.

Fixes: 71e0bbde0d88 ("net: dsa: Add support for platform data")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 960219d2f862..5b9dea81d617 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -478,14 +478,15 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
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
2.14.3
