From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: Fix compile warning
Date: Tue, 23 Sep 2014 09:54:29 -0700
Message-ID: <CAGVrzcZAq+5bhNACCFxhQnKa7AY3WuE1ut_h87+5QoOnovK_4Q@mail.gmail.com>
References: <1411478381-9059-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:59200 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753708AbaIWQzK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 12:55:10 -0400
Received: by mail-ie0-f182.google.com with SMTP id tp5so4541053ieb.27
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 09:55:09 -0700 (PDT)
In-Reply-To: <1411478381-9059-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-09-23 6:19 GMT-07:00 Tobias Klauser <tklauser@distanz.ch>:
> bcmgenet_wol_resume() is only used in bcmgenet_resume(), which is onl=
y
> defined when CONFIG_PM_SLEEP is enabled. This leads to the following
> compile warning when building with !CONFIG_PM_SLEEP:
>
> drivers/net/ethernet/broadcom/genet/bcmgenet.c:1967:12: warning: =E2=80=
=98bcmgenet_wol_resume=E2=80=99 defined but not used [-Wunused-function=
]
>
> Since bcmgenet_resume() is the only user of bcmgenet_wol_resume(), fi=
x
> this by directly inlining the function there.
>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 23 +++++++---------=
-------
>  1 file changed, 7 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers=
/net/ethernet/broadcom/genet/bcmgenet.c
> index 313c400..e852d20 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1964,19 +1964,6 @@ static void bcmgenet_set_hw_addr(struct bcmgen=
et_priv *priv,
>         bcmgenet_umac_writel(priv, (addr[4] << 8) | addr[5], UMAC_MAC=
1);
>  }
>
> -static int bcmgenet_wol_resume(struct bcmgenet_priv *priv)
> -{
> -       /* From WOL-enabled suspend, switch to regular clock */
> -       if (priv->wolopts)
> -               clk_disable_unprepare(priv->clk_wol);
> -
> -       phy_init_hw(priv->phydev);
> -       /* Speed settings must be restored */
> -       bcmgenet_mii_config(priv->dev);
> -
> -       return 0;
> -}
> -
>  /* Returns a reusable dma control register value */
>  static u32 bcmgenet_dma_disable(struct bcmgenet_priv *priv)
>  {
> @@ -2681,9 +2668,13 @@ static int bcmgenet_resume(struct device *d)
>         if (ret)
>                 goto out_clk_disable;
>
> -       ret =3D bcmgenet_wol_resume(priv);
> -       if (ret)
> -               goto out_clk_disable;
> +       /* From WOL-enabled suspend, switch to regular clock */
> +       if (priv->wolopts)
> +               clk_disable_unprepare(priv->clk_wol);
> +
> +       phy_init_hw(priv->phydev);
> +       /* Speed settings must be restored */
> +       bcmgenet_mii_config(priv->dev);
>
>         /* disable ethernet MAC while updating its registers */
>         umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, false);
> --
> 2.0.1
>
>



--=20
=46lorian
