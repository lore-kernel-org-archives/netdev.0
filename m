From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next-2.6] bnx2: avoid compiler warnings
Date: Tue, 3 Nov 2009 10:01:34 -0800
Message-ID: <1257271294.8625.9.camel@HP1>
References: <4AEFF536.1020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3726 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567AbZKCSLE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 13:11:04 -0500
In-Reply-To: <4AEFF536.1020402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2009-11-03 at 01:17 -0800, Eric Dumazet wrote:
> drivers/net/bnx2.c: In function =E2=80=98bnx2_enable_forced_2g5=E2=80=
=99:
> drivers/net/bnx2.c:1447: warning: =E2=80=98bmcr=E2=80=99 may be used =
uninitialized in this function
> drivers/net/bnx2.c: In function =E2=80=98bnx2_disable_forced_2g5=E2=80=
=99:
> drivers/net/bnx2.c:1482: warning: =E2=80=98bmcr=E2=80=99 may be used =
uninitialized in this function
>=20
> One fix would be to have an initial value, but a plain return might b=
e better.

I agree that plain return is better.  Thanks.

Acked-by: Michael Chan <mchan@broadcom.com>

>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>=20
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 08cddb6..539d23b 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -1466,6 +1466,8 @@ bnx2_enable_forced_2g5(struct bnx2 *bp)
>  	} else if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5708) {
>  		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
>  		bmcr |=3D BCM5708S_BMCR_FORCE_2500;
> +	} else {
> +		return;
>  	}
> =20
>  	if (bp->autoneg & AUTONEG_SPEED) {
> @@ -1500,6 +1502,8 @@ bnx2_disable_forced_2g5(struct bnx2 *bp)
>  	} else if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5708) {
>  		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
>  		bmcr &=3D ~BCM5708S_BMCR_FORCE_2500;
> +	} else {
> +		return;
>  	}
> =20
>  	if (bp->autoneg & AUTONEG_SPEED)
>=20


