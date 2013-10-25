From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [gpio:for-next 67/67] pch_gbe_main.c:undefined reference to `devm_gpio_request_one'
Date: Fri, 25 Oct 2013 12:41:57 +0200
Message-ID: <CACRpkdYvOMiBOXRi61LjemMSoafR6kv3XoY=A5E90hwMumdw9A@mail.gmail.com>
References: <52691c0b.BIIOKlR6F81qU+tE%fengguang.wu@intel.com>
	<20131025044027.GA27083@localhost>
	<CACRpkdaJVE44UGRAZ0tnQSArrs+DuVFhVssW6riWmdp8-6E6BQ@mail.gmail.com>
	<1382696677.4970.40.camel@dvhart-mobl4.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	David Cohen <david.a.cohen@linux.intel.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>
To: Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1382696677.4970.40.camel@dvhart-mobl4.amr.corp.intel.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 25, 2013 at 12:24 PM, Darren Hart <dvhart@linux.intel.com> wrote:
> On Fri, 2013-10-25 at 11:34 +0200, Linus Walleij wrote:

> Minnow doesn't currently have a CONFIG_ upstream which can be used to
> force this selection.

Well it wouldn't help with randconfig or allyesconfig anyway.

>> Is there some default y we can add so this gets compiled for this
>> entire board, or shall I set:
>>
>> depends on PCH_GBE
>> default y
>>
>> On the GPIO_LYNXPOINT or GPIO_PCH driver?
>
> Why would GPIO_PCH depend on PCH_GBE? The inverse is certainly true for
> MinnowBoard.

OK this was the wrong idea.

> I had some MinnowBoard Kconfig bits in my early drivers, but they
> included things like CONFIG_MINNOWBOARD which is not upstream (rightly
> so) but it means I don't have a way to conditionally make PCH_GBE
> dependent on GPIO_PCH and GPIOLIB.
>
> I wouldn't object to adding a dependency to GPIO_PCH and GPIOLIB
> unconditionally for PCH_GBE as GPIO_PCH is the same chip... but I don't
> know if David Miller would be amenable to that.

Well we should probably just stick a dependency to GPIOLIB in there.

- It #includes <linux/gpio.h>
- It uses gpiolib functions to do something vital

It was just happy that dummy versions were slotted in until now.

I'll post the following:
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/etherne
index a588ffde9700..f2528262aba7 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -4,7 +4,7 @@

 config PCH_GBE
        tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
-       depends on PCI && (X86 || COMPILE_TEST)
+       depends on PCI && GPIOLIB && (X86 || COMPILE_TEST)
        select MII
        select PTP_1588_CLOCK_PCH
        ---help---

Yours,
Linus Walleij
