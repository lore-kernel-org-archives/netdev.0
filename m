From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/3] dsa: mv88e6xxx: Make mv88e6xxx_wait() timeout verbose
Date: Fri, 19 Aug 2016 00:01:57 +0200
Message-ID: <1471557717-21852-4-git-send-email-andrew@lunn.ch>
References: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38658 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754021AbcHSBzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:55:09 -0400
In-Reply-To: <1471557717-21852-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When mv88e6xxx_wait() returns a timeout, something bad has
happened. Make sure it is noticed by logging an error.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 8c846bce4edf..014b52bd72f1 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -325,6 +325,7 @@ static int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg,
 		usleep_range(1000, 2000);
 	}
 
+	dev_err(chip->dev, "Timeout while waiting for switch\n");
 	return -ETIMEDOUT;
 }
 
-- 
2.8.1
