From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169.c broke for me from 2.6.20.4 to 2.6.21
Date: Thu, 3 May 2007 00:31:36 +0200
Message-ID: <20070502223136.GA19750@electric-eye.fr.zoreil.com>
References: <4636A499.6020709@foks.8m.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jelle Foks <jelle@foks.8m.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44516 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766675AbXEBWeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 18:34:10 -0400
Content-Disposition: inline
In-Reply-To: <4636A499.6020709@foks.8m.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please don't trim the Cc:. The bugs must be processed publicly to feed
the oracle.

Jelle Foks <jelle@foks.8m.com> :
> Francois Romieu wrote:
[...]
> > Can you:
> > - send the output of a 'lspci -vvx'
> >   
> See attached lspci.txt, the ethernet card chip, obviously, at 00:0b.0

Plain old 8169. Ok.

[...]
> > - send the output of mii-tool including hex dump of the registers with
> >   2.6.20.4 and 2.6.21
> >   
> $ sudo /sbin/mii-tool -v -v
> Using SIOCGMIIPHY=0x8947
> eth1: 10 Mbit, half duplex, link ok
>   registers for MII PHY 32:
>     0000 794d 001c c910 0de1 0020 0004 2001
>     0000 0300 0000 1000 1007 f880 0000 3000
>     0060 0c00 0000 0000 0060 0000 009a 0108
>     2740 0088 0000 8000 8400 0000 0000 4830
>   product info: vendor 00:07:32, model 17 rev 0
>   basic mode:   10 Mbit, half duplex
>   basic status: link ok
>   capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
>   advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
>   link partner: 10baseT-HD

1. Can you send the output of mii-tool on the other kernel too ?

2. Any change if you use the patch below on 2.6.21 ? No need to wait for
   minutes if it does not perform better btw.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5b42176..d2082ef 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -525,7 +525,8 @@ static unsigned int rtl8169_tbi_link_ok(void __iomem *ioaddr)
 
 static unsigned int rtl8169_xmii_link_ok(void __iomem *ioaddr)
 {
-	return RTL_R8(PHYstatus) & LinkStatus;
+	return (RTL_R8(PHYstatus) & LinkStatus) ? 1 :
+		(RTL_R8(PHYstatus) & LinkStatus);
 }
 
 static void rtl8169_tbi_reset_enable(void __iomem *ioaddr)

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
