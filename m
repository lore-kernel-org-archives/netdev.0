From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: dsa: loop: Inline unregister_fixed_phys()
Date: Thu, 15 Jun 2017 10:15:52 -0700
Message-ID: <20170615171553.16482-2-f.fainelli@gmail.com>
References: <20170615171553.16482-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33513 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdFORQE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 13:16:04 -0400
Received: by mail-wr0-f196.google.com with SMTP id x23so4356606wrb.0
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 10:16:03 -0700 (PDT)
In-Reply-To: <20170615171553.16482-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a simple function that only gets used in the driver's remove
function, inline it there.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/dsa_loop.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index 79e62593ff4e..fb888593c2e9 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -293,15 +293,6 @@ static struct mdio_driver dsa_loop_drv = {
 
 #define NUM_FIXED_PHYS	(DSA_LOOP_NUM_PORTS - 2)
 
-static void unregister_fixed_phys(void)
-{
-	unsigned int i;
-
-	for (i = 0; i < NUM_FIXED_PHYS; i++)
-		if (phydevs[i])
-			fixed_phy_unregister(phydevs[i]);
-}
-
 static int __init dsa_loop_init(void)
 {
 	struct fixed_phy_status status = {
@@ -320,8 +311,12 @@ module_init(dsa_loop_init);
 
 static void __exit dsa_loop_exit(void)
 {
+	unsigned int i;
+
 	mdio_driver_unregister(&dsa_loop_drv);
-	unregister_fixed_phys();
+	for (i = 0; i < NUM_FIXED_PHYS; i++)
+		if (phydevs[i])
+			fixed_phy_unregister(phydevs[i]);
 }
 module_exit(dsa_loop_exit);
 
-- 
2.9.3
