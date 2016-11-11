From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 02/11] net: dsa: mv88e6xxx: Fix unused variable warning by using variable
Date: Fri, 11 Nov 2016 03:53:34 +0100
Message-ID: <1478832823-31471-3-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34674 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965451AbcKKC6A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:58:00 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 _mv88e6xxx_stats_wait() did not check the return value from
 mv88e6xxx_g1_read(), so the compiler complained about set but unused
 err.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 2c5c37318e31..a4d52f0fdc90 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -771,6 +771,9 @@ static int _mv88e6xxx_stats_wait(struct mv88e6xxx_chip *chip)
 
 	for (i = 0; i < 10; i++) {
 		err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_OP, &val);
+		if (err)
+			return err;
+
 		if ((val & GLOBAL_STATS_OP_BUSY) == 0)
 			return 0;
 	}
-- 
2.10.2
