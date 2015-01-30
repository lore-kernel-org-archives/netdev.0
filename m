From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH] net/tulip: don't warn about unknown ARM architecture
Date: Fri, 30 Jan 2015 14:08:15 -0800
Message-ID: <CAP6odjj5ZQL-x4dV73Jvz2BWU=CPXiWkx5Ot5ZCAEOpD-=B-gA@mail.gmail.com>
References: <1780413.LLpv9s01CB@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	open list <linux-kernel@vger.kernel.org>,
	Grant Grundler <grundler@parisc-linux.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1780413.LLpv9s01CB@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 30, 2015 at 1:58 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> ARM has 32-byte cache lines, which according to the comment in
> the init registers function seems to work best with the default
> value of 0x4800 that is also used on sparc and parisc.
>
> This adds ARM to the same list, to use that default but no
> longer warn about it.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks!
grant

> diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
> index 6aa887e0e1cb..9beb3d34d4ba 100644
> --- a/drivers/net/ethernet/dec/tulip/winbond-840.c
> +++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
> @@ -904,7 +904,7 @@ static void init_registers(struct net_device *dev)
>         }
>  #elif defined(__powerpc__) || defined(__i386__) || defined(__alpha__) || defined(__ia64__) || defined(__x86_64__)
>         i |= 0xE000;
> -#elif defined(CONFIG_SPARC) || defined (CONFIG_PARISC)
> +#elif defined(CONFIG_SPARC) || defined (CONFIG_PARISC) || defined(CONFIG_ARM)
>         i |= 0x4800;
>  #else
>  #warning Processor architecture undefined
>
