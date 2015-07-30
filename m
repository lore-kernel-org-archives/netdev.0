From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: [PATCH] MIPS: Remove all the uses of custom gpio.h
Date: Thu, 30 Jul 2015 22:13:44 +0200
Message-ID: <CAOiHx=n+RDN9ByPmS_7vAW85EnKvN=pQan1+AtZ4B9=fFmQJvA@mail.gmail.com>
References: <1438277338-7246-1-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: MIPS Mailing List <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Florian Fainelli <florian@openwrt.org>,
	Manuel Lauss <manuel.lauss@gmail.com>,
	Joe Perches <joe@perches.com>,
	Daniel Walter <dwalter@google.com>,
	Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Huacai Chen <chenhc@lemote.com>,
	Andrew Bresticker <abrestic@chromium.org>,
	James Hartley <james.hartley@imgtec.com>,
	Paul Burton <paul.burton@imgtec.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Wolfram Sang <wsa@the-dreams.de>,
	Simon Horman <horms+renesas@verge.net.au>,
	Geert Uytterhoeven <geert@linux-m68k.org
To: Alban Bedel <albeu@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438277338-7246-1-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Jul 30, 2015 at 7:28 PM, Alban Bedel <albeu@free.fr> wrote:
> Currently CONFIG_ARCH_HAVE_CUSTOM_GPIO_H is defined for all MIPS
> machines, and each machine type provides its own gpio.h. However
> only a handful really implement the GPIO API, most just forward
> everythings to gpiolib.
>
> The Alchemy machine is notable as it provides a system to allow
> implementing the GPIO API at the board level. But it is not used by
> any board currently supported, so it can also be removed.
>
> For most machine types we can just remove the custom gpio.h, as well
> as the custom wrappers if some exists. Some of the code found in
> the wrappers must be moved to the respective GPIO driver.
>
> A few more fixes are need in some drivers as they rely on linux/gpio.h
> to provides some machine specific definitions, or used asm/gpio.h
> instead of linux/gpio.h for the gpio API.
>
> Signed-off-by: Alban Bedel <albeu@free.fr>
> ---
>
> This patch is based on my previous serie:
> "MIPS: ath79: Move the GPIO driver to drivers/gpio".
>
> It supercede my previous patch named:
> "MIPS: Remove most of the custom gpio.h"
>
> Compared to the previous patch:
> * Fixed gpio_to_irq on jz4740 and rb532
> * Cleaned up alchemy as well
> * Removed asm/gpio.h
>
> For testing I tried to build all mips defconfig, however my toolchain
> couldn't handle a few configs: ip28 malta_qemu_32r6 maltasmvp_eva
> sead3micro. If somebody can test these that would be more than welcome.
>
> Now a few stats about the state of CONFIG_ARCH_HAVE_CUSTOM_GPIO_H
> after appling this patch. Of the 31 supportd arch, 15 still have
> asm/gpio.h, of these 9 are just a "#warning Include linux/gpio.h
> instead of asm/gpio.h". So we have 6 arch left: arm, avr32, blackfin,
> m68k, sh and unicore32. But only m68k and unicore32 really provides
> custom wrappers, all the others only forward to gpiolib.
>
> On the drivers side we only have 13 occurences of '#include
> <asm/gpio.h>' left, mostly in drivers used on ARM SoC.
>
> So the work left to phase out the legacy GPIO is really not that much
> anymore.
>
> Alban
> ---
>  arch/mips/Kconfig                               |   1 -
>  arch/mips/alchemy/Kconfig                       |   7 --
>  arch/mips/alchemy/board-gpr.c                   |   1 +
>  arch/mips/alchemy/board-mtx1.c                  |   1 +
>  arch/mips/alchemy/common/Makefile               |   7 +-
>  arch/mips/alchemy/devboards/db1000.c            |   1 +
>  arch/mips/alchemy/devboards/db1300.c            |   1 +
>  arch/mips/alchemy/devboards/db1550.c            |   1 +
>  arch/mips/alchemy/devboards/pm.c                |   2 +-
>  arch/mips/ar7/gpio.c                            |  12 +-
>  arch/mips/ar7/platform.c                        |   1 -
>  arch/mips/ar7/setup.c                           |   1 -
>  arch/mips/include/asm/gpio.h                    |   6 -
>  arch/mips/include/asm/mach-ar7/ar7.h            |   4 +
>  arch/mips/include/asm/mach-ar7/gpio.h           |  41 -------
>  arch/mips/include/asm/mach-ath25/gpio.h         |  16 ---
>  arch/mips/include/asm/mach-ath79/gpio.h         |  26 -----
>  arch/mips/include/asm/mach-au1x00/gpio-au1000.h | 148 ++----------------------
>  arch/mips/include/asm/mach-au1x00/gpio.h        |  86 --------------
>  arch/mips/include/asm/mach-bcm47xx/gpio.h       |  17 ---
>  arch/mips/include/asm/mach-bcm63xx/gpio.h       |  15 ---
>  arch/mips/include/asm/mach-cavium-octeon/gpio.h |  21 ----
>  arch/mips/include/asm/mach-generic/gpio.h       |  21 ----
>  arch/mips/include/asm/mach-jz4740/gpio.h        |   2 -
>  arch/mips/include/asm/mach-lantiq/gpio.h        |  13 ---
>  arch/mips/include/asm/mach-loongson64/gpio.h    |  36 ------
>  arch/mips/include/asm/mach-pistachio/gpio.h     |  21 ----
>  arch/mips/include/asm/mach-rc32434/gpio.h       |  12 --
>  arch/mips/jz4740/gpio.c                         |  20 ++--
>  arch/mips/pci/pci-lantiq.c                      |   1 -
>  arch/mips/rb532/devices.c                       |   1 +
>  arch/mips/rb532/gpio.c                          |   6 +
>  arch/mips/txx9/generic/setup.c                  |  16 ---
>  drivers/ata/pata_rb532_cf.c                     |   3 +-
>  drivers/gpio/gpio-ath79.c                       |  32 -----
>  drivers/input/misc/rb532_button.c               |   1 +
>  drivers/net/ethernet/ti/cpmac.c                 |   2 +
>  37 files changed, 44 insertions(+), 559 deletions(-)
>  delete mode 100644 arch/mips/include/asm/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-ar7/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-ath25/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-ath79/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-au1x00/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-bcm47xx/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-bcm63xx/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-cavium-octeon/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-generic/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-lantiq/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-loongson64/gpio.h
>  delete mode 100644 arch/mips/include/asm/mach-pistachio/gpio.h
>
> diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
> index cee5f93..6cab2b8 100644

(snip)

> diff --git a/arch/mips/ar7/gpio.c b/arch/mips/ar7/gpio.c
> index d8dbd8f..ae29906 100644
> --- a/arch/mips/ar7/gpio.c
> +++ b/arch/mips/ar7/gpio.c
> @@ -21,7 +21,7 @@
>  #include <linux/module.h>
>  #include <linux/gpio.h>
>
> -#include <asm/mach-ar7/gpio.h>
> +#include <asm/mach-ar7/ar7.h>
>
>  struct ar7_gpio_chip {
>         void __iomem            *regs;
> @@ -94,9 +94,6 @@ static int titan_gpio_direction_input(struct gpio_chip *chip, unsigned gpio)
>         void __iomem *gpio_dir0 = gpch->regs + TITAN_GPIO_DIR_0;
>         void __iomem *gpio_dir1 = gpch->regs + TITAN_GPIO_DIR_1;
>
> -       if (gpio >= TITAN_GPIO_MAX)
> -               return -EINVAL;
> -

This change is not in the patch description. Have you checked that
this cannot happen? And even if so, removing that check would be
something
for an additional patch IMHO.

>         writel(readl(gpio >> 5 ? gpio_dir1 : gpio_dir0) | (1 << (gpio & 0x1f)),
>                         gpio >> 5 ? gpio_dir1 : gpio_dir0);
>         return 0;
> @@ -123,9 +120,6 @@ static int titan_gpio_direction_output(struct gpio_chip *chip,
>         void __iomem *gpio_dir0 = gpch->regs + TITAN_GPIO_DIR_0;
>         void __iomem *gpio_dir1 = gpch->regs + TITAN_GPIO_DIR_1;
>
> -       if (gpio >= TITAN_GPIO_MAX)
> -               return -EINVAL;
> -

same here.

>         titan_gpio_set_value(chip, gpio, value);
>         writel(readl(gpio >> 5 ? gpio_dir1 : gpio_dir0) & ~(1 <<
>                 (gpio & 0x1f)), gpio >> 5 ? gpio_dir1 : gpio_dir0);
> @@ -141,7 +135,7 @@ static struct ar7_gpio_chip ar7_gpio_chip = {
>                 .set                    = ar7_gpio_set_value,
>                 .get                    = ar7_gpio_get_value,
>                 .base                   = 0,
> -               .ngpio                  = AR7_GPIO_MAX,
> +               .ngpio                  = 32,

Maybe move the #define into this file here instead of replacing it
with a magic number?

>         }
>  };
>
> @@ -153,7 +147,7 @@ static struct ar7_gpio_chip titan_gpio_chip = {
>                 .set                    = titan_gpio_set_value,
>                 .get                    = titan_gpio_get_value,
>                 .base                   = 0,
> -               .ngpio                  = TITAN_GPIO_MAX,
> +               .ngpio                  = 51,

same here.



Jonas
