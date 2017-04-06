From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Fix warning with CONFIG_OF=n
Date: Thu,  6 Apr 2017 06:47:35 -0700
Message-ID: <20170406134736.24329-2-f.fainelli@gmail.com>
References: <20170406134736.24329-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35141 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755489AbdDFNrm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:47:42 -0400
Received: by mail-it0-f65.google.com with SMTP id y18so4387291itc.2
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 06:47:42 -0700 (PDT)
In-Reply-To: <20170406134736.24329-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_OF=n, we will see the following warning:

drivers/net/dsa/mv88e6xxx/chip.c:2834:34: warning: 'mv88e6xxx_mdio_external_match' defined but not used [-Wunused-const-variable=]
 static const struct of_device_id mv88e6xxx_mdio_external_match[] = {
                                  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 44ba8cff5631..64cbc4c04907 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2831,11 +2831,13 @@ static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
+#ifdef CONFIG_OF
 static const struct of_device_id mv88e6xxx_mdio_external_match[] = {
 	{ .compatible = "marvell,mv88e6xxx-mdio-external",
 	  .data = (void *)true },
 	{ },
 };
+#endif
 
 static int mv88e6xxx_mdios_register(struct mv88e6xxx_chip *chip,
 				    struct device_node *np)
-- 
2.9.3
