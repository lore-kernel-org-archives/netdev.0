From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH 25/26] isdn: eicon: mark divascapi incompatible with kasan
Date: Fri, 3 Mar 2017 17:20:16 +0300
Message-ID: <6ada42bd-4cc7-4985-3e3b-705cba6e157d@virtuozzo.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
 <20170302163834.2273519-26-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-media@vger.kernel.org>,
        <linux-wireless@vger.kernel.org>,
        <kernel-build-reports@lists.linaro.org>,
        "David S . Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>, <kasan-dev@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170302163834.2273519-26-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/02/2017 07:38 PM, Arnd Bergmann wrote:
> When CONFIG_KASAN is enabled, we have several functions that use rather
> large kernel stacks, e.g.
> 
> drivers/isdn/hardware/eicon/message.c: In function 'group_optimization':
> drivers/isdn/hardware/eicon/message.c:14841:1: warning: the frame size of 864 bytes is larger than 500 bytes [-Wframe-larger-than=]
> drivers/isdn/hardware/eicon/message.c: In function 'add_b1':
> drivers/isdn/hardware/eicon/message.c:7925:1: warning: the frame size of 1008 bytes is larger than 500 bytes [-Wframe-larger-than=]
> drivers/isdn/hardware/eicon/message.c: In function 'add_b23':
> drivers/isdn/hardware/eicon/message.c:8551:1: warning: the frame size of 928 bytes is larger than 500 bytes [-Wframe-larger-than=]
> drivers/isdn/hardware/eicon/message.c: In function 'sig_ind':
> drivers/isdn/hardware/eicon/message.c:6113:1: warning: the frame size of 2112 bytes is larger than 500 bytes [-Wframe-larger-than=]
> 
> To be on the safe side, and to enable a lower frame size warning limit, let's
> just mark this driver as broken when KASAN is in use. I have tried to reduce
> the stack size as I did with dozens of other drivers, but failed to come up
> with a good solution for this one.
> 

This is kinda radical solution.
Wouldn't be better to just increase -Wframe-larger-than for this driver through Makefile?



> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/isdn/hardware/eicon/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/isdn/hardware/eicon/Kconfig b/drivers/isdn/hardware/eicon/Kconfig
> index 6082b6a5ced3..b64496062421 100644
> --- a/drivers/isdn/hardware/eicon/Kconfig
> +++ b/drivers/isdn/hardware/eicon/Kconfig
> @@ -31,6 +31,7 @@ config ISDN_DIVAS_PRIPCI
>  
>  config ISDN_DIVAS_DIVACAPI
>  	tristate "DIVA CAPI2.0 interface support"
> +	depends on !KASAN || BROKEN
>  	help
>  	  You need this to provide the CAPI interface
>  	  for DIVA Server cards.
> 
