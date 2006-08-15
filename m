From: akpm@osdl.org
Subject: [patch 17/41] smctr section fix
Date: Mon, 14 Aug 2006 23:00:06 -0700
Message-ID: <200608150600.k7F6061m012651@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:57234 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965147AbWHOGBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:42 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/tokenring/smctr.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x2ba0) and 'smctr_reset_adapter'
WARNING: drivers/net/tokenring/smctr.o - Section mismatch: reference to .init.text:smctr_probe from .text between 'init_module' (at offset 0x2bf4) and 'smctr_reset_adapter'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tokenring/smctr.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff -puN drivers/net/tokenring/smctr.c~smctr-section-fix drivers/net/tokenring/smctr.c
--- a/drivers/net/tokenring/smctr.c~smctr-section-fix
+++ a/drivers/net/tokenring/smctr.c
@@ -5666,7 +5666,7 @@ module_param_array(io, int, NULL, 0);
 module_param_array(irq, int, NULL, 0);
 module_param(ringspeed, int, 0);
 
-static struct net_device *setup_card(int n)
+static struct net_device * __init setup_card(int n)
 {
 	struct net_device *dev = alloc_trdev(sizeof(struct net_local));
 	int err;
@@ -5696,9 +5696,8 @@ out:
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
-			
 
-int init_module(void)
+int __init init_module(void)
 {
         int i, found = 0;
 	struct net_device *dev;
_
