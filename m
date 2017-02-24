From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH net] net: phy: Fix LED mode in DT single property.
Date: Fri, 24 Feb 2017 11:18:00 -0600
Message-ID: <CAL_JsqK7NO0u1Pf7odD5COLvauXNiNmYj2aa4dCHJEZDzWe1xQ@mail.gmail.com>
References: <1487915942-26039-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Allan.Nielsen@microsemi.com, Andrew Lunn <andrew@lunn.ch>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:60102 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751268AbdBXRTG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Feb 2017 12:19:06 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
        by mail.kernel.org (Postfix) with ESMTP id 4C6D1201FE
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 17:18:23 +0000 (UTC)
Received: from mail-yw0-f169.google.com (mail-yw0-f169.google.com [209.85.161.169])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 0701E2021A
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 17:18:22 +0000 (UTC)
Received: by mail-yw0-f169.google.com with SMTP id q127so12731939ywg.0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 09:18:21 -0800 (PST)
In-Reply-To: <1487915942-26039-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 11:59 PM, Raju Lakkaraju
<Raju.Lakkaraju@microsemi.com> wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
>
> Fix the LED mode DT parameters combine to a single property
> and change the vendor prefix i.e. mscc.
>
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> ---
>  .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 20 ++++-----
>  drivers/net/phy/mscc.c                             | 50 +++++++++++++---------
>  2 files changed, 38 insertions(+), 32 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> index 0eedabe..2253de5 100644
> --- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> +++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> @@ -6,12 +6,12 @@ Required properties:
>                   Documentation/devicetree/bindings/net/phy.txt
>
>  Optional properties:
> -- vsc8531,vddmac       : The vddmac in mV. Allowed values is listed
> +- mscc,vddmac          : The vddmac in mV. Allowed values is listed

It would be nice if these were fixed too for consistency, but you
can't just change them unless you know there's no users already and
supporting both doesn't seem worth it here.

>                           in the first row of Table 1 (below).
>                           This property is only used in combination
>                           with the 'edge-slowdown' property.
>                           Default value is 3300.
> -- vsc8531,edge-slowdown        : % the edge should be slowed down relative to
> +- mscc,edge-slowdown   : % the edge should be slowed down relative to
>                           the fastest possible edge time.
>                           Edge rate sets the drive strength of the MAC
>                           interface output signals.  Changing the
> @@ -27,14 +27,11 @@ Optional properties:
>                           'vddmac'.
>                           Default value is 0%.
>                           Ref: Table:1 - Edge rate change (below).
> -- vsc8531,led-0-mode   : LED mode. Specify how the LED[0] should behave.
> +- mscc,led-mode                : LED mode. Specify how the LED[0] and LED[1] should behave.

Need to be explicit that the length is 2 cells.

>                           Allowed values are define in
>                           "include/dt-bindings/net/mscc-phy-vsc8531.h".
> -                         Default value is VSC8531_LINK_1000_ACTIVITY (1).
> -- vsc8531,led-1-mode   : LED mode. Specify how the LED[1] should behave.
> -                         Allowed values are define in
> -                         "include/dt-bindings/net/mscc-phy-vsc8531.h".
> -                         Default value is VSC8531_LINK_100_ACTIVITY (2).
> +                         Default LED[0] value is VSC8531_LINK_1000_ACTIVITY (1).
> +                         Default LED[1] value is VSC8531_LINK_100_ACTIVITY (2).
>
>  Table: 1 - Edge rate change
>  ----------------------------------------------------------------|
> @@ -66,8 +63,7 @@ Example:
>
>          vsc8531_0: ethernet-phy@0 {
>                  compatible = "ethernet-phy-id0007.0570";
> -                vsc8531,vddmac         = <3300>;
> -                vsc8531,edge-slowdown  = <7>;
> -                vsc8531,led-0-mode     = <LINK_1000_ACTIVITY>;
> -                vsc8531,led-1-mode     = <LINK_100_ACTIVITY>;
> +                mscc,vddmac            = /bits/ 16 <3300>;
> +                mscc,edge-slowdown     = /bits/ 8  <7>;
> +                mscc,led-mode  = <LINK_1000_ACTIVITY LINK_100_ACTIVITY>;
>          };
> diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
> index 650c266..3e7e9d9 100644
> --- a/drivers/net/phy/mscc.c
> +++ b/drivers/net/phy/mscc.c
> @@ -385,11 +385,11 @@ static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
>         if (!of_node)
>                 return -ENODEV;
>
> -       rc = of_property_read_u16(of_node, "vsc8531,vddmac", &vdd);
> +       rc = of_property_read_u16(of_node, "mscc,vddmac", &vdd);
>         if (rc != 0)
>                 vdd = MSCC_VDDMAC_3300;
>
> -       rc = of_property_read_u8(of_node, "vsc8531,edge-slowdown", &sd);
> +       rc = of_property_read_u8(of_node, "mscc,edge-slowdown", &sd);
>         if (rc != 0)
>                 sd = 0;
>
> @@ -403,25 +403,43 @@ static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
>  }
>
>  static int vsc85xx_dt_led_mode_get(struct phy_device *phydev,
> -                                  char *led,
> -                                  u8 default_mode)
> +                                  char *led)
>  {
>         struct device *dev = &phydev->mdio.dev;
>         struct device_node *of_node = dev->of_node;
> -       u8 led_mode;
> -       int err;
> +       struct vsc8531_private *vsc8531 = phydev->priv;
> +       u8 led_0_mode = VSC8531_LINK_1000_ACTIVITY;
> +       u8 led_1_mode = VSC8531_LINK_100_ACTIVITY;
> +       const __be32 *paddr_end;
> +       const __be32 *paddr;
> +       int len;
>
>         if (!of_node)
>                 return -ENODEV;
>
> -       led_mode = default_mode;
> -       err = of_property_read_u8(of_node, led, &led_mode);
> -       if (!err && (led_mode > 15 || led_mode == 7 || led_mode == 11)) {
> -               phydev_err(phydev, "DT %s invalid\n", led);
> +       paddr = of_get_property(of_node, "mscc,led-mode", &len);
> +       if (!paddr)
> +               return -EINVAL;
> +
> +       paddr_end = paddr + (len /= sizeof(*paddr));
> +       while (paddr + 1 < paddr_end) {
> +               led_0_mode = be32_to_cpup(paddr++);
> +               led_1_mode = be32_to_cpup(paddr++);
> +       }
> +
> +       if (!len && (led_0_mode > 15 || led_0_mode == 7 || led_0_mode == 11)) {
> +               phydev_err(phydev, "DT %s-0 invalid\n", led);
>                 return -EINVAL;
>         }
> +       vsc8531->led_0_mode = led_0_mode;
>
> -       return led_mode;
> +       if (!len && (led_1_mode > 15 || led_1_mode == 7 || led_1_mode == 11)) {
> +               phydev_err(phydev, "DT %s-1 invalid\n", led);
> +               return -EINVAL;
> +       }
> +       vsc8531->led_1_mode = led_1_mode;
> +
> +       return 0;
>  }
>
>  #else
> @@ -641,17 +659,9 @@ static int vsc85xx_probe(struct phy_device *phydev)
>         vsc8531->rate_magic = rate_magic;
>
>         /* LED[0] and LED[1] mode */
> -       led_mode = vsc85xx_dt_led_mode_get(phydev, "vsc8531,led-0-mode",
> -                                          VSC8531_LINK_1000_ACTIVITY);
> -       if (led_mode < 0)
> -               return led_mode;
> -       vsc8531->led_0_mode = led_mode;
> -
> -       led_mode = vsc85xx_dt_led_mode_get(phydev, "vsc8531,led-1-mode",
> -                                          VSC8531_LINK_100_ACTIVITY);
> +       led_mode = vsc85xx_dt_led_mode_get(phydev, "mscc,led-mode");
>         if (led_mode < 0)
>                 return led_mode;
> -       vsc8531->led_1_mode = led_mode;
>
>         return 0;
>  }
> --
> 2.7.4
>
