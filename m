From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2 1/3] dt/net: add helper function of_get_phy_mode
Date: Tue, 5 Jul 2011 11:35:12 -0600
Message-ID: <CACxGe6sA5XRJXpJTYC_ZrFUM_YrQOtzJbXK6ANg5W_E3fi0vEg@mail.gmail.com>
References: <1309878839-25743-1-git-send-email-shawn.guo@linaro.org> <1309878839-25743-2-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org, patches@linaro.org,
	David Miller <davem@davemloft.net>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:33434 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab1GERfe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 13:35:34 -0400
Received: by yxi11 with SMTP id 11so1979330yxi.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 10:35:34 -0700 (PDT)
In-Reply-To: <1309878839-25743-2-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2011 at 9:13 AM, Shawn Guo <shawn.guo@linaro.org> wrote:
> It adds the helper function of_get_phy_mode getting phy interface
> from device tree.
>
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> Cc: Grant Likely <grant.likely@secretlab.ca>

Acked-by: Grant Likely <grant.likely@secretlab.ca>

Dave, this should probably get merged via your tree since the rest of
this series depends on it.

g.

> ---
> =A0drivers/of/of_net.c =A0 =A0| =A0 43 ++++++++++++++++++++++++++++++=
+++++++++++++
> =A0include/linux/of_net.h | =A0 =A01 +
> =A02 files changed, 44 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
> index 86f334a..cc117db 100644
> --- a/drivers/of/of_net.c
> +++ b/drivers/of/of_net.c
> @@ -8,6 +8,49 @@
> =A0#include <linux/etherdevice.h>
> =A0#include <linux/kernel.h>
> =A0#include <linux/of_net.h>
> +#include <linux/phy.h>
> +
> +/**
> + * It maps 'enum phy_interface_t' found in include/linux/phy.h
> + * into the device tree binding of 'phy-mode', so that Ethernet
> + * device driver can get phy interface from device tree.
> + */
> +static const char *phy_modes[] =3D {
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_MII] =A0 =A0 =A0 =A0=3D "mii",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_GMII] =A0 =A0 =A0 =3D "gmii",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_SGMII] =A0 =A0 =A0=3D "sgmii",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_TBI] =A0 =A0 =A0 =A0=3D "tbi",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_RMII] =A0 =A0 =A0 =3D "rmii",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_RGMII] =A0 =A0 =A0=3D "rgmii",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_RGMII_ID] =A0 =3D "rgmii-id",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_RGMII_RXID] =3D "rgmii-rxid",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_RGMII_TXID] =3D "rgmii-txid",
> + =A0 =A0 =A0 [PHY_INTERFACE_MODE_RTBI] =A0 =A0 =A0 =3D "rtbi",
> +};
> +
> +/**
> + * of_get_phy_mode - Get phy mode for given device_node
> + * @np: =A0 =A0 =A0 =A0Pointer to the given device_node
> + *
> + * The function gets phy interface string from property 'phy-mode',
> + * and return its index in phy_modes table, or errno in error case.
> + */
> +const int of_get_phy_mode(struct device_node *np)
> +{
> + =A0 =A0 =A0 const char *pm;
> + =A0 =A0 =A0 int err, i;
> +
> + =A0 =A0 =A0 err =3D of_property_read_string(np, "phy-mode", &pm);
> + =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < ARRAY_SIZE(phy_modes); i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcasecmp(pm, phy_modes[i]))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return i;
> +
> + =A0 =A0 =A0 return -ENODEV;
> +}
> +EXPORT_SYMBOL_GPL(of_get_phy_mode);
>
> =A0/**
> =A0* Search the device tree for the best MAC address to use. =A0'mac-=
address' is
> diff --git a/include/linux/of_net.h b/include/linux/of_net.h
> index e913081..f474641 100644
> --- a/include/linux/of_net.h
> +++ b/include/linux/of_net.h
> @@ -9,6 +9,7 @@
>
> =A0#ifdef CONFIG_OF_NET
> =A0#include <linux/of.h>
> +extern const int of_get_phy_mode(struct device_node *np);
> =A0extern const void *of_get_mac_address(struct device_node *np);
> =A0#endif
>
> --
> 1.7.4.1
>
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
