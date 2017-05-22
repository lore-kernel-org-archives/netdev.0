From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 3/3] stmmac: pci: Use dmi_system_id table for retrieving
 PHY addresses
Date: Mon, 22 May 2017 19:59:10 +0300
Message-ID: <CAHp75VfDJEC1HYHX_ebONA26TmNWsCg8LLWaLQ3Xfttm6cPsXA@mail.gmail.com>
References: <cover.1495451529.git.jan.kiszka@siemens.com> <c8e6966227a9c2981e822b2deac8c036651b088c.1495451529.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c8e6966227a9c2981e822b2deac8c036651b088c.1495451529.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 2:12 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> Avoids reimplementation of DMI matching in stmmac_pci_find_phy_addr.

>  struct stmmac_pci_dmi_data {
> -       const char *name;
> -       const char *asset_tag;
> -       unsigned int func;
> +       int func;
>         int phy_addr;
>  };

Perhaps
  struct stmmac_pci_dmi_data {
     unsigned int func;
     int phy_addr;
  };

struct stmmac_pci_info {
  struct stmmac_pci_dmi_data *data;
  size_t nmaps;
 (*setup)(struct plat_stmmacenet_data *plat, struct stmmac_pci_info *info);
};

static const struct stmmac_pci_dmi_data galileo_stmmac_dmi_data[] = {
        {
                 .func = 6,
                 .phy_addr = 1,
        },
};

static struct stmmac_pci_info galileo_pci_info  = {
 .map = galileo_stmmac_dmi_data,
 .nmaps = ARRAY_SIZE(galileo_stmmac_dmi_data),
 .setup = quark_default_setup,
}


?

-- 
With Best Regards,
Andy Shevchenko
