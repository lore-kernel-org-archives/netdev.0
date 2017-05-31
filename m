From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3 5/6] stmmac: pci: Use dmi_system_id table for
 retrieving PHY addresses
Date: Wed, 31 May 2017 21:09:44 +0300
Message-ID: <CAHp75VdUj+FjRm8YNTqFer_GtuHzB4shk3KwQ0bMgQ7Rvd7uFg@mail.gmail.com>
References: <cover.1496129604.git.jan.kiszka@siemens.com> <1ec11df8a4860215c93125f83a04c8c00482a041.1496129604.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1ec11df8a4860215c93125f83a04c8c00482a041.1496129604.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 10:33 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> Avoids reimplementation of DMI matching in stmmac_pci_find_phy_addr.

>  struct stmmac_pci_dmi_data {
> -       const char *name;
> -       const char *asset_tag;
> -       unsigned int func;
> +       int func;
>         int phy_addr;
>  };

Can we use the following instead:

struct stmmac_pci_dmi_data {
       unsigned int *func;
       int *phy_addr;
       size_t nfuncs;
};

or something like

struct stmmac_pci_func_data {
       unsigned int func;
       int phy_addr;
};

struct stmmac_pci_dmi_data {
    struct stmmac_pci_func_data *func;
    size_t nfuncs;
};

(Latter would be better since it allows to use ARRAY_SIZE() and less
error prone for possible asymmetrical amount of values in the former)

?

-- 
With Best Regards,
Andy Shevchenko
