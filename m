From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net v4 2/3] net: libphy: Add stubs to hook IEEE MMD
 Register reads and writes
Date: Mon, 30 Jun 2014 15:53:44 -0700
Message-ID: <CAGVrzcZ6U9PzhwEtm-BPdr7Qv7-v-UDmVkmegUz-Mcr7YTDDSg@mail.gmail.com>
References: <1404092124-18704-1-git-send-email-vbridgers2013@gmail.com> <1404092124-18704-3-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Randy Dunlap <rdunlap@infradead.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, vbridger <vbridger@altera.com>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:56840 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbaF3WyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 18:54:24 -0400
Received: by mail-ob0-f172.google.com with SMTP id uy5so9617630obc.17
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 15:54:24 -0700 (PDT)
In-Reply-To: <1404092124-18704-3-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-29 18:35 GMT-07:00 Vince Bridgers <vbridgers2013@gmail.com>:
> The Micrel ksz9021 PHY does not support standard IEEE standard MMD
> extended register access, therefore requires stubs to fail the read
> register method and do nothing for the write register method when
> libphy attempts to read and/or configure Energy Efficient Ethernet
> features in PHYS that do support those features. This problem
> was observed on an Altera Cyclone V SOC development kit that
> uses the Synopsys EMAC and the Micrel ksz9021 PHY. This patch
> was tested on the same board, and Energy Efficient Ethernet is
> now disabled as expected since the Micrel PHY does not support that
> feature.
>
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> V4: Correct error when editing for V3
> V3: Remove unnecessary returns from void functions.
> V2: Split libphy and Micrel specific changes into 2 patches
>     based on review comments
> ---
>  drivers/net/phy/micrel.c |   22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
>
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index bc7c7d2..40ff138 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -420,6 +420,26 @@ static int ksz8873mll_config_aneg(struct phy_device *phydev)
>         return 0;
>  }
>
> +/* This routine returns -1 as an indication to the caller that the
> + * Micrel ksz9021 10/100/1000 PHY does not support standard IEEE
> + * MMD extended PHY registers.
> + */
> +static int
> +ksz9021_rd_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
> +                     int regnum)
> +{
> +       return -1;
> +}
> +
> +/* This routine does nothing since the Micrel ksz9021 does not support
> + * standard IEEE MMD extended PHY registers.
> + */
> +static void
> +ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
> +                     int regnum, u32 val)
> +{
> +}
> +
>  static struct phy_driver ksphy_driver[] = {
>  {
>         .phy_id         = PHY_ID_KS8737,
> @@ -565,6 +585,8 @@ static struct phy_driver ksphy_driver[] = {
>         .config_intr    = ksz9021_config_intr,
>         .suspend        = genphy_suspend,
>         .resume         = genphy_resume,
> +       .rd_mmd_indirect = ksz9021_rd_mmd_phyreg,
> +       .wr_mmd_indirect = ksz9021_wr_mmd_phyreg,
>         .driver         = { .owner = THIS_MODULE, },
>  }, {
>         .phy_id         = PHY_ID_KSZ9031,
> --
> 1.7.9.5
>



-- 
Florian
