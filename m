From: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Subject: Re: [PATCHv3 (net.git) 2/2] stmmac: fix MDIO settings
Date: Mon, 14 Mar 2016 10:14:06 +0100
Message-ID: <CAG374jDMk3z0rn-eMfRWiw7FUvN_26yjsVc340zvQPFq=XxuLg@mail.gmail.com>
References: <1457703196-15008-1-git-send-email-peppe.cavallaro@st.com> <1457703196-15008-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?Andreas_F=C3=A4rber?= <afaerber@suse.de>,
	fschaefer.oss@googlemail.com, Dinh Nguyen <dinh.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Phil Reid <preid@electromag.com.au>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37798 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933617AbcCNJOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 05:14:47 -0400
Received: by mail-wm0-f54.google.com with SMTP id p65so93185458wmp.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 02:14:46 -0700 (PDT)
In-Reply-To: <1457703196-15008-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

Just one remark below

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 6a52fa1..d2322e9 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c

[snip]

> +static bool stmmac_dt_phy(struct plat_stmmacenet_data *plat,
> +                         struct device_node *np, struct device *dev)
> +{
> +       bool ret = true;
> +
> +       /* If phy-handle property is passed from DT, use it as the PHY */
> +       plat->phy_node = of_parse_phandle(np, "phy-handle", 0);
> +       if (plat->phy_node)
> +               dev_dbg(dev, "Found phy-handle subnode\n");
> +
> +       /* If phy-handle is not specified, check if we have a fixed-phy */
> +       if (!plat->phy_node && of_phy_is_fixed_link(np)) {
> +               if ((of_phy_register_fixed_link(np) < 0))
> +                       return -ENODEV;
> +
stmmac_dt_phy() function should return a Boolean


Best Regards.

Gabriel
