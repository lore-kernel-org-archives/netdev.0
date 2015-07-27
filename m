From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH] MIPS: Remove most of the custom gpio.h
Date: Mon, 27 Jul 2015 15:20:08 +0200
Message-ID: <CACRpkdZon9XHSMyieGDU8F037+4TxyCq=6z5vJwQ3k6QJm6MTg@mail.gmail.com>
References: <1437586416-14735-1-git-send-email-albeu@free.fr>
	<55B131B1.10302@metafoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alban Bedel <albeu@free.fr>,
	Linux MIPS <linux-mips@linux-mips.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Tejun Heo <tj@kernel.org>,
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
	Wolfram Sang <wsa@the-d
To: Lars-Peter Clausen <lars@metafoo.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B131B1.10302@metafoo.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 23, 2015 at 8:25 PM, Lars-Peter Clausen <lars@metafoo.de> wrote:
> On 07/22/2015 07:33 PM, Alban Bedel wrote:
>>
>> diff --git a/arch/mips/jz4740/gpio.c b/arch/mips/jz4740/gpio.c
>> index 54c80d4..3dc500c 100644
>> --- a/arch/mips/jz4740/gpio.c
>> +++ b/arch/mips/jz4740/gpio.c
>> @@ -262,18 +262,6 @@ uint32_t jz_gpio_port_get_value(int port, uint32_t
>> mask)
>>   }
>>   EXPORT_SYMBOL(jz_gpio_port_get_value);
>>
>> -int gpio_to_irq(unsigned gpio)
>> -{
>> -       return JZ4740_IRQ_GPIO(0) + gpio;
>> -}
>> -EXPORT_SYMBOL_GPL(gpio_to_irq);
>
>
> This need to be hooked up the gpio_to_irq() callback of the gpio_chip struct
> of this driver rather than completely removing it. Otherwise this
> functionality will be broken.
>
> Similar for other platforms which implement the function.

Even better is to see if we can convert the driver to
GPIOLIB_IRQCHIP which moves the handling of IRQ mapping
to the gpiolib core. This works for all simple cascading GPIO-with-IRQ
controllers with a local mask register. (Not when the system intcon
and GPIO is mashed up though.)

But no hurry with that.

Yours,
Linus Walleij
