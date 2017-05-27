From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2 2/6] stmmac: pci: Use stmmac_pci_info for all devices
Date: Sat, 27 May 2017 16:13:58 +0300
Message-ID: <CAHp75Ve=CJ-ZRmaAFX+tezMJ4u11v=ptrDDORF485f3_iFEWeg@mail.gmail.com>
References: <cover.1495814872.git.jan.kiszka@siemens.com> <dc0eaa024838f4ef34913aed63315771ac81dcc1.1495814872.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dc0eaa024838f4ef34913aed63315771ac81dcc1.1495814872.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 26, 2017 at 7:07 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> Make stmmac_default_data compatible with stmmac_pci_info.setup and use
> an info structure for all devices. This allows to make the probing more
> regular.


> +#define STMMAC_DEVICE(vendor_id, dev_id, info) {       \
> +       PCI_DEVICE(vendor_id, dev_id),                  \

Perhaps

#define STMMAC_DEVICE(_vid, _did, info) {       \
       PCI_DEVICE(PCI_VENDOR_ID_##_vid, _did),                  \

Or converting defines first to PCI_DEVICE_ID_*
and

#define STMMAC_DEVICE(_vid, _did, info) {       \
       PCI_DEVICE(PCI_VENDOR_ID_##_vid, PCI_DEVICE_ID_##_did),
         \

which I like even better.

> +       .driver_data = (kernel_ulong_t)&info            \
> +       }
> +
>  static const struct pci_device_id stmmac_id_table[] = {
> -       {PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)},
> -       {PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC)},
> -       {PCI_VDEVICE(INTEL, STMMAC_QUARK_ID), (kernel_ulong_t)&quark_pci_info},
> +       STMMAC_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID, stmmac_pci_info),
> +       STMMAC_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC,
> +                     stmmac_pci_info),
> +       STMMAC_DEVICE(PCI_VENDOR_ID_INTEL, STMMAC_QUARK_ID, quark_pci_info),

-- 
With Best Regards,
Andy Shevchenko
