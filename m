From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dsa/mv88e6060: support nonzero mii base address
Date: Mon,  7 Mar 2011 16:49:47 +0100
Message-ID: <1299512987-11152-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: davem@davemloft.net, buytenh@wantstofly.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46573 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab1CGPuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 10:50:19 -0500
Received: by wyg36 with SMTP id 36so4271418wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 07:50:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6060 uses either the lower 16 or upper 16 mii addresses,
depending on the value of the EE_CLK/ADDR4 pin. Support both
configurations by using the sw_addr setting as base address.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 net/dsa/mv88e6060.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/dsa/mv88e6060.c b/net/dsa/mv88e6060.c
index 83277f4..8f4ff5a 100644
--- a/net/dsa/mv88e6060.c
+++ b/net/dsa/mv88e6060.c
@@ -18,7 +18,7 @@
 
 static int reg_read(struct dsa_switch *ds, int addr, int reg)
 {
-	return mdiobus_read(ds->master_mii_bus, addr, reg);
+	return mdiobus_read(ds->master_mii_bus, ds->pd->sw_addr + addr, reg);
 }
 
 #define REG_READ(addr, reg)					\
@@ -34,7 +34,8 @@ static int reg_read(struct dsa_switch *ds, int addr, int reg)
 
 static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 {
-	return mdiobus_write(ds->master_mii_bus, addr, reg, val);
+	return mdiobus_write(ds->master_mii_bus, ds->pd->sw_addr + addr,
+			     reg, val);
 }
 
 #define REG_WRITE(addr, reg, val)				\
@@ -50,7 +51,7 @@ static char *mv88e6060_probe(struct mii_bus *bus, int sw_addr)
 {
 	int ret;
 
-	ret = mdiobus_read(bus, REG_PORT(0), 0x03);
+	ret = mdiobus_read(bus, sw_addr + REG_PORT(0), 0x03);
 	if (ret >= 0) {
 		ret &= 0xfff0;
 		if (ret == 0x0600)
-- 
1.7.2.3

