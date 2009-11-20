From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: ETHOC should depend on HAS_DMA (was: Re: [PATCH] ETHOC:
	fix build breakage on s390)
Date: Fri, 20 Nov 2009 20:19:10 +0100
Message-ID: <10f740e80911201119h6db1e2e1t2c6d40ef1e614094@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Thierry Reding <thierry.reding@avionic-design.de>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:55110 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204AbZKTTTG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 14:19:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2009 at 10:30, Heiko Carstens <heiko.carstens@de.ibm.co=
m> wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
>
> Let driver depend on HAS_IOMEM to avoid build breakage on s390:
>
> =C2=A0CC =C2=A0 =C2=A0 =C2=A0drivers/net/ethoc.o
> drivers/net/ethoc.c: In function 'ethoc_read':
> drivers/net/ethoc.c:221: error: implicit declaration of function 'ior=
ead32'
> drivers/net/ethoc.c: In function 'ethoc_write':
> drivers/net/ethoc.c:226: error: implicit declaration of function 'iow=
rite32'
> drivers/net/ethoc.c: In function 'ethoc_rx':
> drivers/net/ethoc.c:405: error: implicit declaration of function 'mem=
cpy_fromio'
> drivers/net/ethoc.c: In function 'ethoc_start_xmit':
> drivers/net/ethoc.c:828: error: implicit declaration of function 'mem=
cpy_toio'
>
> Cc: Thierry Reding <thierry.reding@avionic-design.de>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> ---
> =C2=A0drivers/net/Kconfig | =C2=A0 =C2=A02 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: linux-2.6/drivers/net/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/drivers/net/Kconfig
> +++ linux-2.6/drivers/net/Kconfig
> @@ -974,7 +974,7 @@ config ENC28J60_WRITEVERIFY
>
> =C2=A0config ETHOC
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tristate "OpenCores 10/100 Mbps Ethernet M=
AC support"
> - =C2=A0 =C2=A0 =C2=A0 depends on NET_ETHERNET
> + =C2=A0 =C2=A0 =C2=A0 depends on NET_ETHERNET && HAS_IOMEM

This is not sufficient, it has to depend on HAS_DMA, too:

=46rom cdb6fc81662e9afd6019221acc7f56d2d7dcd161 Mon Sep 17 00:00:00 200=
1
=46rom: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 20 Nov 2009 20:07:09 +0100
Subject: [PATCH] net: ETHOC should depend on HAS_DMA

When building for Sun 3:

drivers/net/ethoc.c:1091: undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `ethoc_probe':
drivers/net/ethoc.c:965: undefined reference to `dma_alloc_coherent'
drivers/net/ethoc.c:1063: undefined reference to `dma_free_coherent'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8015ecc..9e7c76e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -993,7 +993,7 @@ config ENC28J60_WRITEVERIFY

 config ETHOC
 	tristate "OpenCores 10/100 Mbps Ethernet MAC support"
-	depends on NET_ETHERNET && HAS_IOMEM
+	depends on NET_ETHERNET && HAS_IOMEM && HAS_DMA
 	select MII
 	select PHYLIB
 	select CRC32
--=20
1.6.0.4

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
							    -- Linus Torvalds
