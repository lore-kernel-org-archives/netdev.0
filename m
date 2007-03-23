From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 4/5 2.6.21-rc4] l2tp: pppol2tp kbuild changes
Date: Fri, 23 Mar 2007 23:07:27 GMT
Message-ID: <200703232307.l2NN7Rj4010817@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33023 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992614AbXCWXIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 19:08:11 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1HUsrY-00055Z-Nd
	for netdev@vger.kernel.org; Fri, 23 Mar 2007 18:08:01 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l2NN7Soj010842
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 23:07:28 GMT
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l2NN7Rj4010817
	for netdev@vger.kernel.org; Fri, 23 Mar 2007 23:07:27 GMT
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPPOL2TP]: Modify kbuild for the new pppol2tp driver.

This patch adds a new config option, CONFIG_PPPOL2TP and adds
if_pppol2tp.h to the list of exported headers.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.21-rc4/drivers/net/Kconfig
===================================================================
--- linux-2.6.21-rc4.orig/drivers/net/Kconfig
+++ linux-2.6.21-rc4/drivers/net/Kconfig
@@ -2812,6 +2812,19 @@ config PPPOATM
 	  which can lead to bad results if the ATM peer loses state and
 	  changes its encapsulation unilaterally.
 
+config PPPOL2TP
+	tristate "PPP over L2TP (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && PPP
+	help
+	  Support for PPP-over-L2TP socket family. L2TP is a protocol
+	  used by ISPs and enterprises to tunnel PPP traffic over UDP
+	  tunnels. L2TP is replacing PPTP for VPN uses.
+
+	  This kernel component handles only L2TP data packets: a
+	  userland daemon handles L2TP the control protocol (tunnel
+	  and session setup). One such daemon is OpenL2TP
+	  (http://openl2tp.sourceforge.net/).
+
 config SLIP
 	tristate "SLIP (serial line) support"
 	---help---
Index: linux-2.6.21-rc4/drivers/net/Makefile
===================================================================
--- linux-2.6.21-rc4.orig/drivers/net/Makefile
+++ linux-2.6.21-rc4/drivers/net/Makefile
@@ -119,6 +119,7 @@ obj-$(CONFIG_PPP_DEFLATE) += ppp_deflate
 obj-$(CONFIG_PPP_BSDCOMP) += bsd_comp.o
 obj-$(CONFIG_PPP_MPPE) += ppp_mppe.o
 obj-$(CONFIG_PPPOE) += pppox.o pppoe.o
+obj-$(CONFIG_PPPOL2TP) += pppox.o pppol2tp.o
 
 obj-$(CONFIG_SLIP) += slip.o
 obj-$(CONFIG_SLHC) += slhc.o
Index: linux-2.6.21-rc4/include/linux/Kbuild
===================================================================
--- linux-2.6.21-rc4.orig/include/linux/Kbuild
+++ linux-2.6.21-rc4/include/linux/Kbuild
@@ -220,6 +220,7 @@ unifdef-y += if_fddi.h
 unifdef-y += if_frad.h
 unifdef-y += if_ltalk.h
 unifdef-y += if_link.h
+unifdef-y += if_pppol2tp.h
 unifdef-y += if_pppox.h
 unifdef-y += if_shaper.h
 unifdef-y += if_tr.h
