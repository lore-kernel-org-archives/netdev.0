From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] mark devices with broken LRO implementation
Date: Mon, 6 Dec 2010 09:10:10 -0800
Message-ID: <20101206091010.036cd78b@nehalam>
References: <1291653582-14177-1-git-send-email-leitao@linux.vnet.ibm.com>
	<20101206084824.637d6b29@nehalam>
	<4CFD15F6.7040609@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Breno Leitao <leitao@linux.vnet.ibm.com>,
	Olof Johansson <olof@lixom.net>,
	Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46412 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752986Ab0LFRKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 12:10:13 -0500
In-Reply-To: <4CFD15F6.7040609@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel uses dev_disable_lro to disable Large Receive Offload
for cases where it is inappropriate. But several drivers do not implement
the required hook.  This is a "penalty box" patch to encourage those
drivers to add support for the necessary ethtool set_flags.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
I only found three drivers that are broken. Normally, I would just fix
them; but since changing state in the device is hardware specific, and
I don't have the hardware or specs to do anything useful to fix it.

--- a/drivers/net/Kconfig	2010-12-06 08:52:30.376926696 -0800
+++ b/drivers/net/Kconfig	2010-12-06 09:02:02.013224592 -0800
@@ -28,6 +28,13 @@ menuconfig NETDEVICES
 # that for each of the symbols.
 if NETDEVICES
 
+config BROKEN_LRO
+       bool
+       ---help---
+         Allow drivers with partial Large Receive Offload support. These drivers
+	 do not implement the necessary feature of disabling LRO support via
+	 the ethtool set_flags operation.
+
 config IFB
 	tristate "Intermediate Functional Block support"
 	depends on NET_CLS_ACT
@@ -2675,7 +2682,7 @@ config CHELSIO_T4VF
 
 config EHEA
 	tristate "eHEA Ethernet support"
-	depends on IBMEBUS && INET && SPARSEMEM
+	depends on IBMEBUS && INET && SPARSEMEM && BROKEN_LRO
 	select INET_LRO
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
@@ -2848,7 +2855,7 @@ config NIU
 
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
-	depends on PPC_PASEMI && PCI && INET
+	depends on PPC_PASEMI && PCI && INET && BROKEN_LRO
 	select PHYLIB
 	select INET_LRO
 	help
@@ -2857,7 +2864,7 @@ config PASEMI_MAC
 
 config MLX4_EN
 	tristate "Mellanox Technologies 10Gbit Ethernet support"
-	depends on PCI && INET
+	depends on PCI && INET && BROKEN_LRO
 	select MLX4_CORE
 	select INET_LRO
 	help
