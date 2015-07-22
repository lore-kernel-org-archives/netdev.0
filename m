From: Manuel Lauss <manuel.lauss@gmail.com>
Subject: Re: [PATCH] MIPS: Remove most of the custom gpio.h
Date: Wed, 22 Jul 2015 19:47:18 +0200
Message-ID: <CAOLZvyE=PJUEzp7NqN+g9N1FASxSpfRJTV_uJeAppTxF3sRLhQ@mail.gmail.com>
References: <1437586416-14735-1-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux-MIPS <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Florian Fainelli <florian@openwrt.org>,
	Joe Perches <joe@perches.com>,
	Daniel Walter <dwalter@google.com>,
	Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Huacai Chen <chenhc@lemote.com>,
	Andrew Bresticker <abrestic@chromium.org>,
	James Hartley <james.hartley@imgtec.com>,
	Paul Burton <paul.burton@imgtec.com>,
	Waldemar Brodkorb <wbx@openadk.org>,
	James Hogan <james.hogan@imgtec.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	Levente Kurusa <levex@linux.com>,
	abdoulaye berthe <berthe.ab@gmail.com>,
	Wolfram Sa
To: Alban Bedel <albeu@free.fr>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1437586416-14735-1-git-send-email-albeu@free.fr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 22, 2015 at 7:33 PM, Alban Bedel <albeu@free.fr> wrote:
> Currently CONFIG_ARCH_HAVE_CUSTOM_GPIO_H is defined for all MIPS
> machines, and each machine type provides its own gpio.h. However only
> the Alchemy machine really use the feature, all other machines only
> use the default wrappers.
>
> For most machine types we can just remove the custom gpio.h, as well
> as the custom wrappers if some exists. A few more fixes are need in
> a few drivers as they rely on linux/gpio.h to provides some machine
> specific definitions, or used asm/gpio.h instead of linux/gpio.h for
> the gpio API.
>
> Signed-off-by: Alban Bedel <albeu@free.fr>
> ---
>
> This patch is based on my previous serie:
> "MIPS: ath79: Move the GPIO driver to drivers/gpio".
>
> For testing I tried to build all mips defconfig, however my toolchain
> couldn't handle a few configs: ip28 malta_qemu_32r6 maltasmvp_eva
> sead3micro. If somebody can test these that would be more than welcome.
>
> It might well be that some more drivers for MIPS devices that are not
> enabled in the defconfig will break because of this change, so more
> testing would be nice :)
>
> Regarding Alchemy I'm not sure what to do. It use a little more
> complex setup, quoting arch/mips/include/asm/mach-au1x00/gpio.h:
>
> /* Linux gpio framework integration.
> *
> * 4 use cases of Alchemy GPIOS:
> *(1) GPIOLIB=y, ALCHEMY_GPIO_INDIRECT=y:
> *       Board must register gpiochips.
> *(2) GPIOLIB=y, ALCHEMY_GPIO_INDIRECT=n:
> *       A gpiochip for the 75 GPIOs is registered.
> *
> *(3) GPIOLIB=n, ALCHEMY_GPIO_INDIRECT=y:
> *       the boards' gpio.h must provide the linux gpio wrapper
> functions,
> *
> *(4) GPIOLIB=n, ALCHEMY_GPIO_INDIRECT=n:
> *       inlinable gpio functions are provided which enable access to the
> *       Au1300 gpios only by using the numbers straight out of the data-
> *       sheets.
>
> * Cases 1 and 3 are intended for boards which want to provide their own
> * GPIO namespace and -operations (i.e. for example you have 8 GPIOs
> * which are in part provided by spare Au1300 GPIO pins and in part by
> * an external FPGA but you still want them to be accssible in linux
> * as gpio0-7. The board can of course use the alchemy_gpioX_* functions
> * as required).
> */
>
> This sound to me like this is really not needed anymore. Is there any
> users of this left, or can it just go?

There are no in-tree users of this, but a few out-of-tree ones (all made by me)
Does it have to be removed?  Is it blocking anything?

Manuel
