From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: dsa: Move ports assignment closer to error checking
Date: Thu, 26 Jan 2017 10:28:08 -0800
Message-ID: <20170126182808.13435-5-f.fainelli@gmail.com>
References: <20170126182808.13435-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33485 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdAZSfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:35:47 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so22964300pgd.0
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 10:35:21 -0800 (PST)
In-Reply-To: <20170126182808.13435-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the assignment of ports in _dsa_register_switch() closer to where
it is checked, no functional change. Re-order declarations to be
preserve the inverted christmas tree style.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 4c11619a818b..75f5d1f8554b 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -586,8 +586,8 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
 	struct device_node *np = dev->of_node;
-	struct device_node *ports = dsa_get_ports(ds, np);
 	struct dsa_switch_tree *dst;
+	struct device_node *ports;
 	u32 tree, index;
 	int i, err;
 
@@ -595,6 +595,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	if (err)
 		return err;
 
+	ports = dsa_get_ports(ds, np);
 	if (IS_ERR(ports))
 		return PTR_ERR(ports);
 
-- 
2.9.3
