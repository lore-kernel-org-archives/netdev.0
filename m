From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH] net: ftmac100: fix scheduling while atomic during PHY
 link status change
Date: Thu, 28 Apr 2011 17:11:35 +0800
Message-ID: <BANLkTinB1FiHYX1KoO90UepmhQdXZs0eEg@mail.gmail.com>
References: <BANLkTi=gcFB4mbmWKu4neep77Jp8R4HWGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?UmF0YmVydCBQby1ZdSBDaHVhbmco6I6K5Y2a5a6HKQ==?=
	<ratbert@faraday-tech.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Adam Jaremko <adam.jaremko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56572 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab1D1JL4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 05:11:56 -0400
Received: by fxm17 with SMTP id 17so1678211fxm.19
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 02:11:55 -0700 (PDT)
In-Reply-To: <BANLkTi=gcFB4mbmWKu4neep77Jp8R4HWGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Adam,

2011/4/27 Adam Jaremko <adam.jaremko@gmail.com>:
> Signed-off-by: Adam Jaremko <adam.jaremko@gmail.com>
> ---
> =C2=A0drivers/net/ftmac100.c | =C2=A0 =C2=A08 ++++----
> =C2=A01 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ftmac100.c b/drivers/net/ftmac100.c
> index a316619..9bd7746 100644
> --- a/drivers/net/ftmac100.c
> +++ b/drivers/net/ftmac100.c
> @@ -139,11 +139,11 @@ static int ftmac100_reset(struct ftmac100 *priv=
)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 * that hardware reset completed (what the f*ck).
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 * We still need to wait for a while.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 usleep_range(500, 1000);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 udelay(500);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 usleep_range(1000,=
 10000);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 udelay(1000);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_err(netdev, "software reset failed\=
n");
> @@ -772,7 +772,7 @@ static int ftmac100_mdio_read(struct net_device
> *netdev, int phy_id, int reg)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((phycr & F=
TMAC100_PHYCR_MIIRD) =3D=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return phycr & FTMAC100_PHYCR_MIIRDATA;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 usleep_range(100, =
1000);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 udelay(100);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_err(netdev, "mdio read timed out\n"=
);
> @@ -801,7 +801,7 @@ static void ftmac100_mdio_write(struct net_device
> *netdev, int phy_id, int reg,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((phycr & F=
TMAC100_PHYCR_MIIWR) =3D=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 usleep_range(100, =
1000);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 udelay(100);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_err(netdev, "mdio write timed out\n=
");
> --
> 1.7.4.4
>

Not sure if your patch is indeed corrupt or it's my fault
while downloading patch from gmail:

ERROR: patch seems to be corrupt (line wrapped?)
#62: FILE: drivers/net/ftmac100.c:771:
*netdev, int phy_id, int reg)

total: 1 errors, 0 warnings, 31 lines checked

ftmac100-fix.patch has style problems, please review.  If any of these =
errors
are false positives report them to the maintainer, see
CHECKPATCH in MAINTAINERS.


Except that,

Acked-by: Po-Yu Chuang <ratbert@faraday-tech.com>

best regards,
Po-Yu Chuang
