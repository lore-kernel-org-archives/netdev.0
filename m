From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Subject: [PATCH v2 net-next] dsa:mv88e6xxx: allow address 0x1 in smi_init
Date: Tue,  3 Jan 2017 10:49:09 +0100
Message-ID: <1483436949-4527-1-git-send-email-volodymyr.bendiuga@gmail.com>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34521 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756045AbdACJtv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 04:49:51 -0500
Received: by mail-lf0-f68.google.com with SMTP id d16so29696878lfb.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 01:49:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>

Some devices, such as the mv88e6097 do have ADDR[0] external and so it
is possible to configure the device to use SMI address 0x1. Remove the
restriction, as there are boards using this address.

Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 4da379f..173ea97 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4234,10 +4234,6 @@ static void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
 static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
 			      struct mii_bus *bus, int sw_addr)
 {
-	/* ADDR[0] pin is unavailable externally and considered zero */
-	if (sw_addr & 0x1)
-		return -EINVAL;
-
 	if (sw_addr == 0)
 		chip->smi_ops = &mv88e6xxx_smi_single_chip_ops;
 	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_MULTI_CHIP))
-- 
2.7.4
