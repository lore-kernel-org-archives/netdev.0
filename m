From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 2/7] phy: miphy365x: Pass sysconfig register offsets via
 syscfg dt property.
Date: Wed, 19 Nov 2014 10:42:55 +0000
Message-ID: <20141119104255.GI13959@x1>
References: <1416385632-5832-1-git-send-email-peter.griffin@linaro.org>
 <1416385632-5832-3-git-send-email-peter.griffin@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	srinivas.kandagatla@gmail.com, maxime.coquelin@st.com,
	patrice.chotard@st.com, peppe.cavallaro@st.com, kishon@ti.com,
	arnd@arndb.de, netdev@vger.kernel.org, devicetree@vger.kernel.org,
	alexandre.torgue@st.com
To: Peter Griffin <peter.griffin@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36134 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755964AbaKSKnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 05:43:03 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so760223igd.1
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 02:43:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416385632-5832-3-git-send-email-peter.griffin@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Nov 2014, Peter Griffin wrote:

> Based on Arnds review comments here https://lkml.org/lkml/2014/11/13/=
161, update
> the miphy365 phy driver to access sysconfig register offsets via sysc=
fg dt property.
>=20
> This is because the reg property should not be mixing address spaces =
like it does
> currently for miphy365. This change then also aligns us to how other =
platforms such
> as keystone and bcm7445 pass there syscon offsets via DT.
>=20
> This patch breaks DT compatibility, but this platform is considered W=
IP, and is only
> used by a few developers who are upstreaming support for it. This cha=
nge has been done
> as a single atomic commit to ensure it is bisectable.

You should wrap your lines sooner (70-75 chars).

> Signed-off-by: Peter Griffin <peter.griffin@linaro.org>
> ---
>  .../devicetree/bindings/phy/phy-miphy365x.txt      | 15 +++++------
>  arch/arm/boot/dts/stih416.dtsi                     | 10 ++++----
>  drivers/phy/phy-miphy365x.c                        | 29 ++++++++----=
----------
>  3 files changed, 23 insertions(+), 31 deletions(-)

[...]

> diff --git a/drivers/phy/phy-miphy365x.c b/drivers/phy/phy-miphy365x.=
c
> index 801afaf..7308afe 100644
> --- a/drivers/phy/phy-miphy365x.c
> +++ b/drivers/phy/phy-miphy365x.c

[...]

>  		phy_set_drvdata(phy, miphy_dev->phys[port]);
> +
>  		port++;
> +		/*sysconfig offsets are not indexed from zero */

You're missing a ' ' afrer '/*'.

Probably better do say what they _are_ indexed from, rather than what
they're not.

> +		ret =3D of_property_read_u32_index(np, "st,syscfg", port,
> +					&miphy_phy->ctrlreg);
> +		if (ret) {
> +			dev_err(&pdev->dev, "No sysconfig offset found\n");
> +			return ret;
> +		}
>  	}
> =20
>  	provider =3D devm_of_phy_provider_register(&pdev->dev, miphy365x_xl=
ate);

--=20
Lee Jones
Linaro STMicroelectronics Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
