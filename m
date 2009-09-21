From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Set SKY2_HW_RAM_BUFFER in sky2_init
Date: Mon, 21 Sep 2009 23:08:52 +0900
Message-ID: <4AB788F4.90503@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f171.google.com ([209.85.216.171]:56354 "EHLO
	mail-px0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756156AbZIUOP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 10:15:59 -0400
Received: by pxi1 with SMTP id 1so2445536pxi.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2009 07:16:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SKY2_HW_RAM_BUFFER bit in hw->flags was checked in sky2_mac_init(),
 before being set later in sky2_up().

Setting SKY2_HW_RAM_BUFFER in sky2_init() where other hw->flags are set
 should avoid this problem recurring.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 4bb52e9..68d256b 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1497,7 +1497,6 @@ static int sky2_up(struct net_device *dev)
 	if (ramsize > 0) {
 		u32 rxspace;
 
-		hw->flags |= SKY2_HW_RAM_BUFFER;
 		pr_debug(PFX "%s: ram buffer %dK\n", dev->name, ramsize);
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
@@ -2926,6 +2925,9 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 			++hw->ports;
 	}
 
+	if (sky2_read8(hw, B2_E_0))
+		hw->flags |= SKY2_HW_RAM_BUFFER;
+
 	return 0;
 }
 
-- 
1.5.6.5

