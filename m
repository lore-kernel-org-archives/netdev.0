From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ethernet: ks8851_mll fix rx frame buffer overflow
Date: Tue, 27 Mar 2012 07:39:31 -0700
Message-ID: <1332859171.10620.0.camel@edumazet-laptop>
References: <20120327130144.GA555@recalcati>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Thomas Meyer <thomas@m3y3r.de>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	netdev@vger.kernel.org, raffaele.recalcati@bticino.it
To: Davide Ciminaghi <ciminaghi@gnudd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56954 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab2C0Ojg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 10:39:36 -0400
Received: by eaaq12 with SMTP id q12so1836283eaa.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 07:39:35 -0700 (PDT)
In-Reply-To: <20120327130144.GA555@recalcati>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 mars 2012 =C3=A0 15:01 +0200, Davide Ciminaghi a =C3=A9crit=
 :
> If interrupts are disabled long enough to allow for more than
> 32 frames to accumulate in the MAC's internal buffers, a buffer
> overflow occurs. This patch fixes the problem by making the
> driver's frame_head_info buffer bigger enough.
>=20
> Signed-off-by: Davide Ciminaghi <ciminaghi@gnudd.com>
> Signed-off-by: Raffaele Recalcati <raffaele.recalcati@bticino.it>
> ---
>  drivers/net/ethernet/micrel/ks8851_mll.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/e=
thernet/micrel/ks8851_mll.c
> index 2784bc7..a158e89 100644
> --- a/drivers/net/ethernet/micrel/ks8851_mll.c
> +++ b/drivers/net/ethernet/micrel/ks8851_mll.c
> @@ -40,7 +40,7 @@
>  #define	DRV_NAME	"ks8851_mll"
> =20
>  static u8 KS_DEFAULT_MAC_ADDRESS[] =3D { 0x00, 0x10, 0xA1, 0x86, 0x9=
5, 0x11 };
> -#define MAX_RECV_FRAMES			32
> +#define MAX_RECV_FRAMES			256
>  #define MAX_BUF_SIZE			2048
>  #define TX_BUF_SIZE			2000
>  #define RX_BUF_SIZE			2000

How can this fix the problem for good ?
