From: Krzysztof Helt <krzysztof.h1@poczta.fm>
Subject: [PATCH] correct handling of return value from
 platform_device_register_simple
Date: Mon, 2 Jun 2008 20:46:31 +0200
Message-ID: <20080602204631.f11c5891.krzysztof.h1@poczta.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp239.poczta.interia.pl ([217.74.64.239]:3572 "EHLO
	smtp239.poczta.interia.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbYFBSog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 14:44:36 -0400
Received: from poczta.interia.pl (mi05.te.interia.pl [10.217.12.5])
	by smtp239.poczta.interia.pl (INTERIA.PL) with ESMTP id BD279D4F9C
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2008 20:44:14 +0200 (CEST)
Received: from krzysio.net (host-87-99-61-239.lanet.net.pl [87.99.61.239])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by www.poczta.fm (INTERIA.PL) with ESMTP id E8B8EBE18AF
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2008 20:44:11 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Helt <krzysztof.h1@wp.pl>

The correct way to check return value from the
platform_device_register_simple is to use 
the IS_ERR() function.

Signed-off-by: Krzysztof Helt <krzysztof.h1@wp.pl>
---
This patch was made against 2.6.26-rc2-mm1.


diff -urp linux-mm1/drivers/net/niu.c linux-new/drivers/net/niu.c
--- linux-mm1/drivers/net/niu.c	2008-05-27 21:58:31.894983318 +0200
+++ linux-new/drivers/net/niu.c	2008-06-02 20:39:51.466114138 +0200
@@ -8186,7 +8186,7 @@ static struct niu_parent * __devinit niu
 
 	plat_dev = platform_device_register_simple("niu", niu_parent_index,
 						   NULL, 0);
-	if (!plat_dev)
+	if (IS_ERR(plat_dev))
 		return NULL;
 
 	for (i = 0; attr_name(niu_parent_attributes[i]); i++) {
diff -urp linux-mm1/drivers/net/phy/fixed.c linux-new/drivers/net/phy/fixed.c
--- linux-mm1/drivers/net/phy/fixed.c	2008-05-27 21:57:21.406974006 +0200
+++ linux-new/drivers/net/phy/fixed.c	2008-06-02 20:32:43.506107910 +0200
@@ -208,8 +208,8 @@ static int __init fixed_mdio_bus_init(vo
 	int ret;
 
 	pdev = platform_device_register_simple("Fixed MDIO bus", 0, NULL, 0);
-	if (!pdev) {
-		ret = -ENOMEM;
+	if (IS_ERR(pdev)) {
+		ret = PTR_ERR(pdev);
 		goto err_pdev;
 	}
 


----------------------------------------------------------------------
Podbij Dziki Zachod!Gra strategiczna online
Sprawdz >>> http://link.interia.pl/f1dff

