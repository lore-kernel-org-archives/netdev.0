From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [PATCH] powerpc/ep8248e: phylib needs NET_SCHED to build
Date: Wed, 20 May 2009 14:27:07 +0200 (CEST)
Message-ID: <alpine.LRH.2.00.0905201425540.5871@vixen.sonytel.be>
References: <1242821902-16836-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:33007 "EHLO
	pophost.sonytel.be" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755812AbZETM1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 08:27:08 -0400
In-Reply-To: <1242821902-16836-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 May 2009, Alexander Beregalov wrote:
> Fix this build error:
> drivers/built-in.o: In function `phy_state_machine':
> drivers/net/phy/phy.c:893: undefined reference to 'netif_carrier_off'
> drivers/net/phy/phy.c:854: undefined reference to 'netif_carrier_on'
>=20
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---
>  arch/powerpc/platforms/82xx/Kconfig |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/arch/powerpc/platforms/82xx/Kconfig b/arch/powerpc/platf=
orms/82xx/Kconfig
> index 7c7df40..36a3e58 100644
> --- a/arch/powerpc/platforms/82xx/Kconfig
> +++ b/arch/powerpc/platforms/82xx/Kconfig
> @@ -31,6 +31,9 @@ config EP8248E
>  	select 8260
>  	select FSL_SOC
>  	select PHYLIB
> +	select NET
> +	select NETDEVICE
> +	select NET_SCHED
>  	select MDIO_BITBANG
>  	help
>  	  This enables support for the Embedded Planet EP8248E board.

Why is there a `select PHYLIB' at the platform level? Shouldn't it be i=
n
drivers/net/Kconfig, near the appropriate network driver? That way peop=
le can
build kernels without networking support, if they want.

With kind regards,

Geert Uytterhoeven
Software Architect
Techsoft Centre

Technology and Software Centre Europe
The Corporate Village =B7 Da Vincilaan 7-D1 =B7 B-1935 Zaventem =B7 Bel=
gium

Phone:    +32 (0)2 700 8453
=46ax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 =B7 RPR Brussels
=46ortis =B7 BIC GEBABEBB =B7 IBAN BE41293037680010
