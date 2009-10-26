From: Raimonds Cicans <ray@apollo.lv>
Subject: r8169: Fix card drop incoming VLAN tagged MTU byte large jumbo frames
Date: Mon, 26 Oct 2009 22:52:37 +0200
Message-ID: <4AE60C15.3040206@apollo.lv>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040106060606070807070000"
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.apollo.lv ([80.232.168.197]:52446 "EHLO smtp5.apollo.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550AbZJZVDO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 17:03:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040106060606070807070000
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


--------------040106060606070807070000
Content-Type: text/plain;
 name="r8169-vlan-jumbo.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8169-vlan-jumbo.patch"

r8169 card drop incoming VLAN tagged MTU byte large jumbo frames

It looks to compare current and maximal packet sizes hardware use
'<' operator, not '<='.

Bug introduced by patch:
r8169: fix crash when large packets are received

Signed-off-by: Raimonds Cicans <ray@apollo.lv>

---

--- linux-2.6.31/drivers/net/r8169.c.orig	2009-10-26 20:57:47.256658618 +0200
+++ linux-2.6.31/drivers/net/r8169.c	2009-10-26 19:48:25.807252812 +0200
@@ -2365,7 +2365,7 @@ static u16 rtl_rw_cpluscmd(void __iomem 
 static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_buf_sz)
 {
 	/* Low hurts. Let's disable the filtering. */
-	RTL_W16(RxMaxSize, rx_buf_sz);
+	RTL_W16(RxMaxSize, rx_buf_sz + 1);
 }
 
 static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)

--------------040106060606070807070000--
