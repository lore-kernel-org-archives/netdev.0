From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [PATCH 26/26] kasan: rework Kconfig settings
Date: Fri, 3 Mar 2017 17:51:37 +0300
Message-ID: <125a8ea6-35d7-9d37-3841-eebb37fce515@virtuozzo.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
 <20170302163834.2273519-27-arnd@arndb.de>
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
In-Reply-To: <20170302163834.2273519-27-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/02/2017 07:38 PM, Arnd Bergmann wrote:

> 
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 97d62c2da6c2..27c838c40a36 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -216,10 +216,9 @@ config ENABLE_MUST_CHECK
>  config FRAME_WARN
>  	int "Warn for stack frames larger than (needs gcc 4.4)"
>  	range 0 8192
> -	default 0 if KASAN
> -	default 2048 if GCC_PLUGIN_LATENT_ENTROPY
> +	default 3072 if KASAN_EXTRA
>  	default 1024 if !64BIT
> -	default 2048 if 64BIT
> +	default 1280 if 64BIT

This looks unrelated. Also, it means that now we have 1280 with KASAN=y && KASAN_EXTRA=n.
Judging from changelog I assume that this hunk slipped here from the follow up series.

>  	help
>  	  Tell gcc to warn at build time for stack frames larger than this.
>  	  Setting this too low will cause a lot of warnings.
> @@ -499,7 +498,7 @@ config DEBUG_OBJECTS_ENABLE_DEFAULT
>  
>  config DEBUG_SLAB
>  	bool "Debug slab memory allocations"
> -	depends on DEBUG_KERNEL && SLAB && !KMEMCHECK
> +	depends on DEBUG_KERNEL && SLAB && !KMEMCHECK && !KASAN
>  	help
>  	  Say Y here to have the kernel do limited verification on memory
>  	  allocation as well as poisoning memory on free to catch use of freed
> @@ -511,7 +510,7 @@ config DEBUG_SLAB_LEAK
>  
>  config SLUB_DEBUG_ON
>  	bool "SLUB debugging on by default"
> -	depends on SLUB && SLUB_DEBUG && !KMEMCHECK
> +	depends on SLUB && SLUB_DEBUG && !KMEMCHECK && !KASAN

Why? SLUB_DEBUG_ON works with KASAN.

>  	default n
>  	help
>  	  Boot with debugging on by default. SLUB boots by default with
