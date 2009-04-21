From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] [net, 83xx] ucc_geth.c: Fix upsmr setting in RMII mode
Date: Tue, 21 Apr 2009 18:51:11 +0800
Message-ID: <2a27d3730904210351s870f015gb896a4b874b3024b@mail.gmail.com>
References: <49ED859B.30904@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shlomi Gridish <gridish@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: hs@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:29288 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbZDUKvM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 06:51:12 -0400
Received: by an-out-0708.google.com with SMTP id d40so1164158and.1
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 03:51:11 -0700 (PDT)
In-Reply-To: <49ED859B.30904@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 4:36 PM, Heiko Schocher <hs@denx.de> wrote:
> If using the UCC on a MPC8360 in RMII mode, don;t set
> UCC_GETH_UPSMR_RPM bit in the upsmr register.
>
> Signed-off-by: Heiko Schocher <hs@denx.de>

Acked-by: Li Yang <leoli@freescale.com>

> ---
> =C2=A0drivers/net/ucc_geth.c | =C2=A0 =C2=A03 ++-
> =C2=A01 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index d3f39e8..44f8392 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -1394,7 +1394,8 @@ static int adjust_enet_interface(struct ucc_get=
h_private *ugeth)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(ugeth->phy_interface =3D=3D=
 PHY_INTERFACE_MODE_RGMII_RXID) ||
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(ugeth->phy_interface =3D=3D=
 PHY_INTERFACE_MODE_RGMII_TXID) ||
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(ugeth->phy_interface =3D=3D=
 PHY_INTERFACE_MODE_RTBI)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 upsmr |=3D UCC_GET=
H_UPSMR_RPM;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ugeth->phy_int=
erface !=3D PHY_INTERFACE_MODE_RMII)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 upsmr |=3D UCC_GETH_UPSMR_RPM;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (ugeth-=
>max_speed) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case SPEED_10:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0upsmr |=3D UCC_GETH_UPSMR_R10M;
