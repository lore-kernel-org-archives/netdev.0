From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH] PCI: Add quirk to initialize REG_BASE_ADDR to 0 for
 Broadcom TIGON3 chips.
Date: Mon, 9 Dec 2013 17:32:09 -0700
Message-ID: <CAErSpo7-rRUAJVkfb1Zjdd3c8aMeSdhnLyFvpJggkN4168-ESg@mail.gmail.com>
References: <1386633442-12509-1-git-send-email-natg@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Nat Gurumoorthy <natg@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1386633442-12509-1-git-send-email-natg@google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 9, 2013 at 4:57 PM, Nat Gurumoorthy <natg@google.com> wrote:
> The new tg3 driver leaves REG_BASE_ADDR (PCI config offset 120)
> uninitialized. From power on reset this register may have garbage in it. The
> Register Base Address register defines the device local address of a
> register. The data pointed to by this location is read or written using
> the Register Data register (PCI config offset 128). When REG_BASE_ADDR has
> garbage any read or write of Register Data Register (PCI 128) will cause the
> PCI bus to lock up. The TCO watchdog will fire and bring down the system.
>
> Signed-off-by: <natg@google.com>
> ---
>  drivers/pci/quirks.c | 138 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 138 insertions(+)
>
> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> index 3a02717..b9a289b 100644
> --- a/drivers/pci/quirks.c
> +++ b/drivers/pci/quirks.c
> @@ -3461,3 +3461,141 @@ int pci_dev_specific_acs_enabled(struct pci_dev *dev, u16 acs_flags)
>
>         return -ENOTTY;
>  }
> +
> +/*
> + * This is a quirk is to initialize REG_BASE_ADDR at PCI config offset 120
> + * to 0 for all Broadcom devices controlled by the TIGON3 driver.
> + */
> +static void tg3_init_reg_base_addr(struct pci_dev *dev)
> +{
> +       pci_write_config_dword(dev, 120, 0);
> +}
> +
> +
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5700,
> +                       tg3_init_reg_base_addr);

Wow, this looks like a maintenance nightmare :)  It wouldn't be quite
so bad if we knew that Broadcom were changing this register so it had
a defined state after reset.  If we have to add IDs for every new chip
to this list, that will really be a hassle.  And it's not a very
obvious failure, so the list would only be updated haphazardly.

"lspci -x" only shows the first 64 bytes, and the man page warns that
"lspci -xxx", which dumps all config space, causes some PCI devices to
crash.  So it seems a little odd that the /sys/.../config file gives
us 256 bytes (at least).  I don't know the history of that size,
though.  Hmmm...

Bjorn

> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5701,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5702,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5703,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5704,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5702FE,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705_2,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705M,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705M_2,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5702X,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5703X,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5704S,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5702A3,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5703A3,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5782,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5788,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5789,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901_2,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5704S_2,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705F,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5721,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5722,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751M,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751F,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5752,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5752M,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5753,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5753M,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5753F,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5754,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5754M,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5755,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5755M,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5756,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5786,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787M,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787F,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5714,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5714S,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5715,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5715S,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5780,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5780S,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5781,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5906,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5906M,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5784,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5764,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5723,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761E,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_SYSKONNECT,
> +                       PCI_DEVICE_ID_SYSKONNECT_9DXX,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_SYSKONNECT,
> +                       PCI_DEVICE_ID_SYSKONNECT_9MXX,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1001,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1003,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC9100,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_TIGON3,
> +                       tg3_init_reg_base_addr);
> +DECLARE_PCI_FIXUP_EARLY(0x10cf, 0x11a2, tg3_init_reg_base_addr);
> --
> 1.8.5.1
>
