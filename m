From: Matt Burgess <matthew@linuxfromscratch.org>
Subject: iproute2-3.6.0 assumes presence of iptables
Date: Tue, 02 Oct 2012 19:01:32 +0100
Message-ID: <1349200892.11088.4.camel@kyoto.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-8xov9mtYo1+PjJw3y2En"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from quantum.linuxfromscratch.org ([216.171.237.234]:60235 "EHLO
	quantum.linuxfromscratch.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751691Ab2JBSKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 14:10:32 -0400
Received: from [192.168.0.5] (5ad574d1.bb.sky.com [90.213.116.209])
	by quantum.linuxfromscratch.org (Postfix) with ESMTPA id D95A4140F0
	for <netdev@vger.kernel.org>; Tue,  2 Oct 2012 12:01:33 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8xov9mtYo1+PjJw3y2En
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi,

When compiling iproute2-3.6.0 on a host that doesn't have iptables available, I get the following error:

gcc -Wall -Wstrict-prototypes -O2 -I../include -DRESOLVE_HOSTNAMES
-DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE
-DCONFIG_GACT -DCONFIG_GACT_PROB -DYY_NO_INPUT   -c -o em_ipset.o
em_ipset.c
em_ipset.c:26:21: fatal error: xtables.h: No such file or directory

Fixed by the following patch, which guards the building of em_ipset.o on
the presence of suitable headers.

Thanks,

Matt.

--=-8xov9mtYo1+PjJw3y2En
Content-Disposition: attachment; filename="iproute2-3.6.0-ipset-1.patch"
Content-Type: text/x-patch; name="iproute2-3.6.0-ipset-1.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff -Naur iproute2-3.6.0.orig/tc/Makefile iproute2-3.6.0/tc/Makefile
--- iproute2-3.6.0.orig/tc/Makefile	2012-10-01 15:39:21.000000000 +0000
+++ iproute2-3.6.0/tc/Makefile	2012-10-02 17:45:31.605612832 +0000
@@ -52,7 +52,9 @@
 TCMODULES += q_fq_codel.o
 
 ifeq ($(TC_CONFIG_IPSET), y)
-  TCMODULES += em_ipset.o
+  ifeq ($(TC_CONFIG_XT), y)
+    TCMODULES += em_ipset.o
+  endif
 endif
 
 TCSO :=

--=-8xov9mtYo1+PjJw3y2En--
