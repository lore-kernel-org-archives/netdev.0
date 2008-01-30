From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] via-rhine.c:rhine_hw_init() must be __devinit
Date: Wed, 30 Jan 2008 22:02:05 +0200
Message-ID: <20080130200205.GI29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rl@hellgate.ch, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:40660 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbYA3UBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:01:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thie patch fixes the following section mismatch:

<--  snip  -->

...
WARNING: drivers/net/built-in.o(.text+0xdd840): Section mismatch in reference from the function rhine_hw_init() to the function .devinit.text:rhine_reload_eeprom()
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
a79db62b73dab2b71fa2f47398fd39364d7aae31 
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 87c180b..7c851b1 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -606,7 +606,7 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 }
 #endif
 
-static void rhine_hw_init(struct net_device *dev, long pioaddr)
+static void __devinit rhine_hw_init(struct net_device *dev, long pioaddr)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 

