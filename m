From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2] stmmac: Add support for SIMATIC IOT2000 platform
Date: Tue, 2 May 2017 11:02:44 +0300
Message-ID: <CAHp75VdnCtCrKoMSMUfqpVruG0hJjY99wntUaqfk2C3qTccSzA@mail.gmail.com>
References: <aa7a7f82-7933-1a97-12c4-b51efab498c9@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Sascha Weisenberger <sascha.weisenberger@siemens.com>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <aa7a7f82-7933-1a97-12c4-b51efab498c9@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 2, 2017 at 10:58 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> The IOT2000 is industrial controller platform, derived from the Intel
> Galileo Gen2 board. The variant IOT2020 comes with one LAN port, the
> IOT2040 has two of them. They can be told apart based on the board asset
> tag in the DMI table.
>
> Based on patch by Sascha Weisenberger.
>
> Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
> Signed-off-by: Sascha Weisenberger <sascha.weisenberger@siemens.com>

Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>

> ---
>
> Changes in v2:
> - reformatted match conditions [Andy]
>
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 26 +++++++++++++++++++++++-
>  1 file changed, 25 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index 5c9e462276b9..11d2229e536b 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -32,6 +32,7 @@
>   */
>  struct stmmac_pci_dmi_data {
>         const char *name;
> +       const char *asset_tag;
>         unsigned int func;
>         int phy_addr;
>  };
> @@ -46,6 +47,7 @@ struct stmmac_pci_info {
>  static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
>  {
>         const char *name = dmi_get_system_info(DMI_BOARD_NAME);
> +       const char *asset_tag = dmi_get_system_info(DMI_BOARD_ASSET_TAG);
>         unsigned int func = PCI_FUNC(info->pdev->devfn);
>         struct stmmac_pci_dmi_data *dmi;
>
> @@ -57,8 +59,12 @@ static int stmmac_pci_find_phy_addr(struct stmmac_pci_info *info)
>                 return 1;
>
>         for (dmi = info->dmi; dmi->name && *dmi->name; dmi++) {
> -               if (!strcmp(dmi->name, name) && dmi->func == func)
> +               if (!strcmp(dmi->name, name) && dmi->func == func) {
> +                       /* If asset tag is provided, match on it as well. */
> +                       if (dmi->asset_tag && strcmp(dmi->asset_tag, asset_tag))
> +                               continue;
>                         return dmi->phy_addr;
> +               }
>         }
>
>         return -ENODEV;
> @@ -142,6 +148,24 @@ static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
>                 .func = 6,
>                 .phy_addr = 1,
>         },
> +       {
> +               .name = "SIMATIC IOT2000",
> +               .asset_tag = "6ES7647-0AA00-0YA2",
> +               .func = 6,
> +               .phy_addr = 1,
> +       },
> +       {
> +               .name = "SIMATIC IOT2000",
> +               .asset_tag = "6ES7647-0AA00-1YA2",
> +               .func = 6,
> +               .phy_addr = 1,
> +       },
> +       {
> +               .name = "SIMATIC IOT2000",
> +               .asset_tag = "6ES7647-0AA00-1YA2",
> +               .func = 7,
> +               .phy_addr = 1,
> +       },
>         {}
>  };
>



-- 
With Best Regards,
Andy Shevchenko
