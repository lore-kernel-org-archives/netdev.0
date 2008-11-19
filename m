From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: PHYLIB dependency in kernel 2.6.27.6
Date: Wed, 19 Nov 2008 14:09:33 +0000 (GMT)
Message-ID: <alpine.LFD.1.10.0811191359170.22228@ftp.linux-mips.org>
References: <a278970e0811161427r2f941e10jafbc8ab1d425d64e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Luca Tiburzio <luca.tiburzio@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([213.58.128.207]:36114 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbYKSOJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 09:09:46 -0500
In-Reply-To: <a278970e0811161427r2f941e10jafbc8ab1d425d64e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Nov 2008, Luca Tiburzio wrote:

> in make process of linux 2.6.27.6 the PHYLIB depends on
> 
> NETDEVICES && !S390 && NET_ETHERNET
> 
> but if I enable only
> 
> Ethernet (1000 Mbit) (NETDEV_1000)
> i loose visibility of PHYLIB
> 
> it should be better that  PHYLIB depends on:
> NETDEVICES && !S390 && (NET_ETHERNET || NETDEV_1000)

 Well, practice shows selecting PHYLIB via a reverse dependency is 
probably the most reasonable approach, but given the option is enabled for 
explicit selection otherwise for legacy Ethernet devices, it may make 
sense to do so for Gigabit devices too.  Not sure about 10Gb, but here is 
a patch from my pile I prepared a while ago, but haven't submitted it 
yet.  Feel free to push it further if you find it useful.  Please note 
netdev is the right list for networking matters.

  Maciej

---
 Make PHYLIB available for selection for NETDEV_1000 too.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
patch-2.6.26-rc1-20080505-phy-1000-1
diff -up --recursive --new-file linux-2.6.26-rc1-20080505.macro/drivers/net/phy/Kconfig linux-2.6.26-rc1-20080505/drivers/net/phy/Kconfig
--- linux-2.6.26-rc1-20080505.macro/drivers/net/phy/Kconfig	2008-05-17 05:57:43.000000000 +0000
+++ linux-2.6.26-rc1-20080505/drivers/net/phy/Kconfig	2008-05-17 06:09:49.000000000 +0000
@@ -5,7 +5,7 @@
 menuconfig PHYLIB
 	tristate "PHY Device support and infrastructure"
 	depends on !S390
-	depends on NET_ETHERNET
+	depends on NET_ETHERNET || NETDEV_1000
 	help
 	  Ethernet controllers are usually attached to PHY
 	  devices.  This option provides infrastructure for
