From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/3] dsa: mv88e6xxx: Use mv88e6xx_wait in mv88e6xxx_update()
Date: Fri, 19 Aug 2016 00:01:56 +0200
Message-ID: <1471557717-21852-3-git-send-email-andrew@lunn.ch>
References: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38654 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754301AbcHSBzB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:55:01 -0400
In-Reply-To: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that mv88e6xx_wait() iterated on a counter than a fixed time
interval, it implements the same mechanism as mv88e6xxx_update() uses.
So use it in mv88e6xx_wait().

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ac8e9af4879f..8c846bce4edf 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -333,20 +333,12 @@ static int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
 			    u16 update)
 {
 	u16 val;
-	int i, err;
+	int err;
 
 	/* Wait until the previous operation is completed */
-	for (i = 0; i < 16; ++i) {
-		err = mv88e6xxx_read(chip, addr, reg, &val);
-		if (err)
-			return err;
-
-		if (!(val & BIT(15)))
-			break;
-	}
-
-	if (i == 16)
-		return -ETIMEDOUT;
+	err = mv88e6xxx_wait(chip, addr, reg, BIT(15));
+	if (err)
+		return err;
 
 	/* Set the Update bit to trigger a write operation */
 	val = BIT(15) | update;
-- 
2.8.1
