From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: r6040: bad udelay call, build failure on ARM with R6040=m
Date: Mon, 25 Aug 2008 23:05:09 +0200
Message-ID: <200808252305.10448.florian.fainelli@telecomint.eu>
References: <20080825120502.GA13700@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org,
	Martin Michlmayr <tbm@cyrius.com>
To: Martin Michlmayr <tbm@cyrius.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:48876 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbYHYVHs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 17:07:48 -0400
In-Reply-To: <20080825120502.GA13700@deprecation.cyrius.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Martin,

Le Monday 25 August 2008 14:05:02 Martin Michlmayr, vous avez =E9crit=A0=
:
> r6040 fails to build on ARM with:
>
> ERROR: "__bad_udelay" [drivers/net/r6040.ko] undefined!
> make[1]: *** [__modpost] Error 1
>
> __bad_udelay is specifically designed on ARM to fail when udelay is
> called in a bad way.  arch/arm/include/asm/delay.h has this to say
> about __bad_udelay:

Please find/test the patch below :
--
=46rom: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH] r6040: fix bad usage of udelay

This patch fixes the bad usage of udelay(5000), which in turns is a
mdelay(5). It causes compilation for ARM where udelay maximum value
is checked.

Reported-by: Martin Michlmayr <tbm@cyrius.com>
Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index d453987..d837bef 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -364,7 +364,7 @@ static void r6040_init_mac_regs(struct net_device *=
dev)
 	/* Reset internal state machine */
 	iowrite16(2, ioaddr + MAC_SM);
 	iowrite16(0, ioaddr + MAC_SM);
-	udelay(5000);
+	mdelay(5);
=20
 	/* MAC Bus Control Register */
 	iowrite16(MBCR_DEFAULT, ioaddr + MBCR);
@@ -800,7 +800,7 @@ static void r6040_mac_address(struct net_device *de=
v)
 	iowrite16(0x01, ioaddr + MCR1); /* Reset MAC */
 	iowrite16(2, ioaddr + MAC_SM); /* Reset internal state machine */
 	iowrite16(0, ioaddr + MAC_SM);
-	udelay(5000);
+	mdelay(5);
=20
 	/* Restore MAC Address */
 	adrp =3D (u16 *) dev->dev_addr;
