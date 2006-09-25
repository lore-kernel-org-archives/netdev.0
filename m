From: akpm@osdl.org
Subject: [patch 09/11] b44: fix eeprom endianess issue
Date: Mon, 25 Sep 2006 16:39:23 -0700
Message-ID: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16308 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751712AbWIYXjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:39:32 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

This fixes eeprom read on big-endian architectures.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/b44.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/b44.c~b44-fix-eeprom-endianess-issue drivers/net/b44.c
--- a/drivers/net/b44.c~b44-fix-eeprom-endianess-issue
+++ a/drivers/net/b44.c
@@ -2055,7 +2055,7 @@ static int b44_read_eeprom(struct b44 *b
 	u16 *ptr = (u16 *) data;
 
 	for (i = 0; i < 128; i += 2)
-		ptr[i / 2] = readw(bp->regs + 4096 + i);
+		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
 
 	return 0;
 }
_
