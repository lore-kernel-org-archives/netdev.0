From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH] MIPS: Remove all the uses of custom gpio.h
Date: Mon, 3 Aug 2015 09:13:27 +0200
Message-ID: <CACRpkdbUhYysC+mGuJY6Y8kd18LQLoWu+av81+ZD4UZo2nM-Yw@mail.gmail.com>
References: <1438277338-7246-1-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux MIPS <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Tejun Heo <tj@kernel.org>,
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
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Varka Bhadram <varkabhadram@gmail.com>,
	Masan
To: Alban Bedel <albeu@free.fr>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1438277338-7246-1-git-send-email-albeu@free.fr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Very good job being done here.
Reviewed-by: Linus Walleij <linus.walleij@linaro.org>

I guess this better go in through the MIPS tree.
Given all the OpenWRT ports using MIPS this is excellent
progress for a large hobbyist community.

Yours,
Linus Walleij
