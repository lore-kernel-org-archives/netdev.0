From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2 5/6] stmmac: pci: Use dmi_system_id table for
 retrieving PHY addresses
Date: Sat, 27 May 2017 16:28:50 +0300
Message-ID: <CAHp75VeLVs6LK=_=e_2B+huZLENe6V-8SMNLiEEi+4h_uqmvMg@mail.gmail.com>
References: <cover.1495814872.git.jan.kiszka@siemens.com> <6e12b2e63c7eaab6db937a99fedf79ec806d176f.1495814872.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6e12b2e63c7eaab6db937a99fedf79ec806d176f.1495814872.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 26, 2017 at 7:07 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> Avoids reimplementation of DMI matching in stmmac_pci_find_phy_addr.

>  struct stmmac_pci_dmi_data {
> -       const char *name;
> -       const char *asset_tag;
> -       unsigned int func;
> +       int func;
>         int phy_addr;
>  };

Can we leave unsigned type here...

> -static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
> +static const struct stmmac_pci_dmi_data galileo_stmmac_dmi_data[] = {

> +       {-1, -1},
> +};

> +static const struct stmmac_pci_dmi_data iot2040_stmmac_dmi_data[] = {

> +       {-1, -1},
> +};

...and avoid this not so standard terminators?

> +               .matches = {
> +                       DMI_EXACT_MATCH(DMI_BOARD_NAME, "GalileoGen2"),
> +               },

> +               .driver_data = (void *)galileo_stmmac_dmi_data,

Can't be slightly better

             .driver_data = &galileo_stmmac_dmi_data,

?

-- 
With Best Regards,
Andy Shevchenko
