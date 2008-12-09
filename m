From: holger@eitzenberger.org
Subject: [patch 3/7] bonding: fix compile error if debug enabled
Date: Tue, 09 Dec 2008 21:07:53 +0100
Message-ID: <20081209201447.431916236@eitzenberger.org>
References: <20081209200750.490739902@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:56390 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbYLIUOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 15:14:50 -0500
Content-Disposition: inline; filename=bonding-fix-compile-error-in-debug-output.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is what I get if debug is enabled:

drivers/net/bonding/bond_ipv6.c: In function 'bond_na_send':
drivers/net/bonding/bond_ipv6.c:75: error: 'slave' undeclared (first use in this function)
drivers/net/bonding/bond_ipv6.c:75: error: (Each undeclared identifier is reported only once
drivers/net/bonding/bond_ipv6.c:75: error: for each function it appears in.)

This patch fixes that.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_ipv6.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_ipv6.c	2008-12-05 23:13:47.000000000 +0100
+++ bonding-2.6/drivers/net/bonding/bond_ipv6.c	2008-12-05 23:13:59.000000000 +0100
@@ -75,7 +75,7 @@
 	addrconf_addr_solict_mult(daddr, &mcaddr);
 
 	dprintk("ipv6 na on slave %s: dest %pI6, src %pI6\n",
-	       slave->name, &mcaddr, daddr);
+	       slave_dev->name, &mcaddr, daddr);
 
 	skb = ndisc_build_skb(slave_dev, &mcaddr, daddr, &icmp6h, daddr,
 			      ND_OPT_TARGET_LL_ADDR);

-- 
