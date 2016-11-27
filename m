From: =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>
Subject: [PATCH] mv88e6xxx: Fix mv88e6xxx_g1_irq_free() interrupt count
Date: Sun, 27 Nov 2016 21:43:44 +0100
Message-ID: <1480279424-7830-1-git-send-email-afaerber@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-arm-kernel@lists.infradead.org,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        =?UTF-8?q?Bed=C5=99icha=20Ko=C5=A1atu?= <bedrich.kosata@nic.cz>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53484 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752693AbcK0UoG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 15:44:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mv88e6xxx_g1_irq_setup() sets up chip->g1_irq.nirqs interrupt mappings,
so free the same amount. This will be 8 or 9 in practice, less than 16.

Fixes: dc30c35be720 ("net: dsa: mv88e6xxx: Implement interrupt support.")
Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Andreas Färber <afaerber@suse.de>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 98302358ceb9..95b9efb33ec7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -421,7 +421,7 @@ static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
 
 	free_irq(chip->irq, chip);
 
-	for (irq = 0; irq < 16; irq++) {
+	for (irq = 0; irq < chip->g1_irq.nirqs; irq++) {
 		virq = irq_find_mapping(chip->g1_irq.domain, irq);
 		irq_dispose_mapping(virq);
 	}
-- 
2.6.6
