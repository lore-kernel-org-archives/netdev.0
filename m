From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/5] net: dsa: allow deferred probing
Date: Thu,  5 Mar 2015 12:35:05 -0800
Message-ID: <1425587708-26786-3-git-send-email-f.fainelli@gmail.com>
References: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36787 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbbCEUgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 15:36:15 -0500
Received: by pdbnh10 with SMTP id nh10so45504697pdb.3
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 12:36:14 -0800 (PST)
In-Reply-To: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing a different model to register DSA switches,
update dsa_of_probe() and dsa_probe() to return -EPROBE_DEFER where
appropriate.

Failure to find a phandle or Device Tree property is still fatal, but
looking up the internal device structure associated with a Device Tree
node is something that might need to be delayed based on driver probe
ordering.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d804364150bd..79879d01488a 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -583,7 +583,7 @@ static int dsa_of_probe(struct device *dev)
 
 	mdio_bus = of_mdio_find_bus(mdio);
 	if (!mdio_bus)
-		return -EINVAL;
+		return -EPROBE_DEFER;
 
 	ethernet = of_parse_phandle(np, "dsa,ethernet", 0);
 	if (!ethernet)
@@ -591,7 +591,7 @@ static int dsa_of_probe(struct device *dev)
 
 	ethernet_dev = of_find_device_by_node(ethernet);
 	if (!ethernet_dev)
-		return -ENODEV;
+		return -EPROBE_DEFER;
 
 	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
 	if (!pd)
@@ -718,7 +718,7 @@ static int dsa_probe(struct platform_device *pdev)
 
 	dev = dev_to_net_device(pd->netdev);
 	if (dev == NULL) {
-		ret = -EINVAL;
+		ret = -EPROBE_DEFER;
 		goto out;
 	}
 
-- 
2.1.0
