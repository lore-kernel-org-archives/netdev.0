From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [PATCH 2/2] myri10ge: use ioremap_wc
Date: Sun, 10 Aug 2008 15:38:44 +0300
Message-ID: <20080810123844.GG2486@deprecation.cyrius.com>
References: <488447E7.2060505@myri.com> <48844831.9040102@myri.com> <20080810112500.GA8060@deprecation.cyrius.com> <489ED823.6000005@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:3964 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421AbYHJMmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Aug 2008 08:42:08 -0400
Content-Disposition: inline
In-Reply-To: <489ED823.6000005@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Brice Goglin <brice@myri.com> [2008-08-10 13:59]:
> > This change leads to a compilation failure on (at least) arm:
> >
> >   CC [M]  drivers/net/myri10ge/myri10ge.o
> > drivers/net/myri10ge/myri10ge.c: In function =E2=80=98myri10ge_prob=
e=E2=80=99:
> > drivers/net/myri10ge/myri10ge.c:3725: error: implicit declaration o=
f function =E2=80=98ioremap_wc=E2=80=99
> > drivers/net/myri10ge/myri10ge.c:3725: warning: assignment makes poi=
nter from integer without a cast
> > make[3]: *** [drivers/net/myri10ge/myri10ge.o] Error 1
>=20
> Isn't arm's asm/io.h supposed to get
> #ifndef ARCH_HAS_IOREMAP_WC
> #define ioremap_wc ioremap_nocache
> #endif
> from asm-generic/iomap.h since ARCH_HAS_IOREMAP_WC isn't defined on a=
rm ?

arch/arm/include/asm/io.h doesn't include asm-generic/iomap.h.  When I
add this includes, myri10ge compiles.

Russell, any comments on the change below?

diff --git a/arch/arm/include/asm/io.h b/arch/arm/include/asm/io.h
index 94a95d7..eb71224 100644
--- a/arch/arm/include/asm/io.h
+++ b/arch/arm/include/asm/io.h
@@ -26,6 +26,7 @@
 #include <linux/types.h>
 #include <asm/byteorder.h>
 #include <asm/memory.h>
+#include <asm-generic/iomap.h>
=20
 /*
  * ISA I/O bus memory addresses are 1:1 with the physical address.

--=20
Martin Michlmayr
http://www.cyrius.com/
