From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: unconditionally set ATU trunk
Date: Tue, 28 Mar 2017 15:09:43 -0400
Message-ID: <20170328190943.18320-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51424 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751996AbdC1TLm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 15:11:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the trunk member of the mv88e6xxx_atu_entry structure regardless its
value, so that uninitialized structures gets the correct boolean value.

Note that no mainline code is affected by the current behavior.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 831434bc5c13..fa7e7db5171b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -128,9 +128,7 @@ static int mv88e6xxx_g1_atu_data_read(struct mv88e6xxx_chip *chip,
 
 	entry->state = val & 0xf;
 	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
-		if (val & GLOBAL_ATU_DATA_TRUNK)
-			entry->trunk = true;
-
+		entry->trunk = !!(val & GLOBAL_ATU_DATA_TRUNK);
 		entry->portvec = (val >> 4) & mv88e6xxx_port_mask(chip);
 	}
 
-- 
2.12.1
