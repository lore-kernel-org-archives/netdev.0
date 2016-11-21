From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 02/11] net: dsa: mv88e6xxx: Fix unused variable warning by using variable
Date: Mon, 21 Nov 2016 23:26:56 +0100
Message-ID: <1479767225-13789-3-git-send-email-andrew@lunn.ch>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47722 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754434AbcKUW2L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:28:11 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 _mv88e6xxx_stats_wait() did not check the return value from
 mv88e6xxx_g1_read(), so the compiler complained about set but unused
 err.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 062b9128a58d..c0152125680f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -787,6 +787,9 @@ static int _mv88e6xxx_stats_wait(struct mv88e6xxx_chip *chip)
 
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
