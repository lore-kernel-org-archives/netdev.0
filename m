From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] net/fec: add KSZ9021RN phy fixup
Date: Mon, 12 Dec 2011 10:56:48 -0200
Message-ID: <CAOMZO5DNRrt7ULuBkh9y8bz2_fpCHOcSWxAbJOqTHA2Nrv1V_w@mail.gmail.com>
References: <1323684558-16796-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, patches@linaro.org, jgq516@gmail.com,
	eric.miao@linaro.org, shawn.guo@linaro.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org
To: Richard Zhao <richard.zhao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44039 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565Ab1LLM4u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 07:56:50 -0500
Received: by eaaj10 with SMTP id j10so591476eaa.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 04:56:49 -0800 (PST)
In-Reply-To: <1323684558-16796-1-git-send-email-richard.zhao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2011 at 8:09 AM, Richard Zhao <richard.zhao@linaro.org>=
 wrote:
> For imx6q sabrelite board, set phy RGMII pad skew.
>
> Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
> ---
> =C2=A0drivers/net/ethernet/freescale/fec.c | =C2=A0 19 ++++++++++++++=
+++++
> =C2=A01 files changed, 19 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ether=
net/freescale/fec.c
> index 112af9b..d3b4463 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -1513,6 +1513,21 @@ static inline void fec_reset_phy(struct platfo=
rm_device *pdev)
> =C2=A0}
> =C2=A0#endif /* CONFIG_OF */
>
> +/* For imx6q sabrelite board: set KSZ9021RN RGMII pad skew */
> +static int ksz9021rn_phy_fixup(struct phy_device *phydev)
> +{
> + =C2=A0 =C2=A0 =C2=A0 /* min rx data delay */
> + =C2=A0 =C2=A0 =C2=A0 phy_write(phydev, 0x0b, 0x8105);
> + =C2=A0 =C2=A0 =C2=A0 phy_write(phydev, 0x0c, 0x0000);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* max rx/tx clock delay, min rx/tx control de=
lay */
> + =C2=A0 =C2=A0 =C2=A0 phy_write(phydev, 0x0b, 0x8104);
> + =C2=A0 =C2=A0 =C2=A0 phy_write(phydev, 0x0c, 0xf0f0);
> + =C2=A0 =C2=A0 =C2=A0 phy_write(phydev, 0x0b, 0x104);
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;

This should go to drivers/net/phy/micrel.c.

Regards,

=46abio Estevam
