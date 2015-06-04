From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] net: dsa: mv88e6xxx: Fix deadlock by double lock
Date: Fri,  5 Jun 2015 01:10:09 +0200
Message-ID: <1433459409-16488-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51530 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbbFDXPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 19:15:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool -S on a DSA interface can deadlock for some switches because
the same lock is taken twice. Use the register read function which
expects the lock to be already held.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Fixes: 31888234b736 ("net: dsa: mv88e6xxx: Replace stats mutex with SMI mutex")
---
 drivers/net/dsa/mv88e6xxx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4f2b8b7565b0..261a0301e403 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -758,8 +758,8 @@ static void _mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 		u32 high = 0;
 
 		if (s->reg >= 0x100) {
-			ret = mv88e6xxx_reg_read(ds, REG_PORT(port),
-						 s->reg - 0x100);
+			ret = _mv88e6xxx_reg_read(ds, REG_PORT(port),
+						  s->reg - 0x100);
 			if (ret < 0)
 				goto error;
 			low = ret;
-- 
2.1.4
