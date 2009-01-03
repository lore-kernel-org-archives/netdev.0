From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] net: fix SONIC_READ definition
Date: Sat, 03 Jan 2009 19:43:24 +0100
Message-ID: <495FB1CC.5090506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:42938 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757984AbZACSnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2009 13:43:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/jazzsonic.c:56:
#define SONIC_READ(reg) (*((volatile unsigned int *)dev->base_addr+reg))

drivers/net/sonic.h:53:
#define SONIC_CAP0             0x24

so drivers/net/jazzsonic.c:143:
val = SONIC_READ(SONIC_CAP0-i);

becomes

val = (*((volatile unsigned int *)dev->base_addr+0x24-i));

That is wrong, isn't it?
------------->8---------8<------------------
Fix SONIC_READ definition

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 334ff9e..b872f23 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -53,7 +53,7 @@ static char jazz_sonic_string[] = "jazzsonic";
 /*
  * Macros to access SONIC registers
  */
-#define SONIC_READ(reg) (*((volatile unsigned int *)dev->base_addr+reg))
+#define SONIC_READ(reg) (*((volatile unsigned int *)dev->base_addr+(reg)))
 
 #define SONIC_WRITE(reg,val)						\
 do {									\
