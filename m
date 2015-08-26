From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH] net: phy: fixed: propagate fixed link values to struct
Date: Wed, 26 Aug 2015 17:57:30 +0300
Message-ID: <55DDD3DA.1040405@list.ru>
References: <1440600508-7531-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Igal.Liberman@freescale.com
To: madalin.bucur@freescale.com, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440600508-7531-1-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

26.08.2015 17:48, Madalin Bucur =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> The fixed link values parsed from the device tree are stored in
> the struct fixed_phy member status. The struct phy_device members
> speed, duplex were not updated.
>=20
> Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> ---
>  drivers/net/phy/fixed_phy.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>=20
> diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.=
c
> index 479b93f..20731fc 100644
> --- a/drivers/net/phy/fixed_phy.c
> +++ b/drivers/net/phy/fixed_phy.c
> @@ -292,6 +292,15 @@ struct phy_device *fixed_phy_register(unsigned i=
nt irq,
>  		return ERR_PTR(-EINVAL);
>  	}
> =20
> +	/* propagate the fixed link values to struct phy_device */
> +	if (status->link) {
> +		phy->link =3D status->link;
Oh, I wonder if you want to initialize phy->link regardless,
outside of the "if (status->link)" block.
Other than that,

Acked-by: Stas Sergeev <stsp@users.sourceforge.net>
