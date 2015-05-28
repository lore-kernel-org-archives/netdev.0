From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: thunderx: add 64-bit dependency
Date: Thu, 28 May 2015 16:00:46 +0200
Message-ID: <5799754.oCDa9qX0W8@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>,
	Sunil Goutham <sgoutham@cavium.com>,
	Maciej Czekaj <mjc@semihalf.com>,
	David Daney <david.daney@cavium.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Ganapatrao Kulkarni <ganapatrao.kulkarni@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>,
	Robert Richter <rrichter@cavium.com>,
	Kamil Rytarowski <kamil@semihalf.com>,
	Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
	Sruthi Vangala <svangala@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:49326 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130AbbE1OBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 10:01:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The thunderx ethernet driver fails to build on architectures
that do not have an atomic readq() and writeq() function for
64-bit PCI bus access:

drivers/net/ethernet/cavium/thunder/thunder_bgx.c: In function 'bgx_reg_read':
include/asm-generic/io.h:195:23: error: implicit declaration of function 'readq' [-Werror=implicit-function-declaration]

It seems impossible to get this driver to work on most 32-bit
hardware, so it's better to add an explicit dependency, in
order to let us keep building 'allmodconfig' kernels on
all architectures.

As the driver is meant for the internal hardware on an arm64 SoC, this
is not a problem for usability. Allowing the build on all 64-bit
architectures rather than just CONFIG_ARM64 on the other hand means that
we get the benefit of build testing on x86.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index 6365fb4242be..fc3d8e3ee807 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -4,7 +4,7 @@
 
 config NET_VENDOR_CAVIUM
 	tristate "Cavium ethernet drivers"
-	depends on PCI
+	depends on PCI && 64BIT
 	---help---
 	  Enable support for the Cavium ThunderX Network Interface
 	  Controller (NIC). The NIC provides the controller and DMA
