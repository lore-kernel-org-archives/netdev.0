From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc91x: improve neponset hack
Date: Fri, 20 Feb 2015 16:23:58 -0500 (EST)
Message-ID: <20150220.162358.1989780304954156949.davem@davemloft.net>
References: <5763365.j5Nvv4LgM3@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	rmk+kernel@arm.linux.org.uk, dbaryshkov@gmail.com,
	linux-kernel@vger.kernel.org, linus.walleij@linaro.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5763365.j5Nvv4LgM3@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 18 Feb 2015 20:47:30 +0100

> The smc91x driver tries to support multiple platforms at compile
> time, but they are mutually exclusive at runtime, and not clearly
> defined.
> 
> Trying to build for CONFIG_SA1100_ASSABET without CONFIG_ASSABET_NEPONSET
> results in this link error:
> 
> drivers/built-in.o: In function `smc_drv_probe':
> :(.text+0x33310c): undefined reference to `neponset_ncr_frob'
> 
> since the neponset_ncr_set function is not defined otherwise.
> 
> Similarly, building for both CONFIG_SA1100_ASSABET and CONFIG_SA1100_PLEB
> results in a different build error:
> 
> smsc/smc91x.c: In function 'smc_drv_probe':
> smsc/smc91x.c:2299:2: error: implicit declaration of function 'neponset_ncr_set' [-Werror=implicit-function-declaration]
>   neponset_ncr_set(NCR_ENET_OSC_EN);
>   ^
> smsc/smc91x.c:2299:19: error: 'NCR_ENET_OSC_EN' undeclared (first use in this function)
>   neponset_ncr_set(NCR_ENET_OSC_EN);
>                    ^
> 
> This is an attempt to fix the call site responsible for both
> errors, making sure we call the function exactly when the driver
> is actually trying to run on the assabet/neponset machine. With
> this patch, I no longer see randconfig build errors in this file.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

I know this isn't the desired long term solution to this problem, but
it's the most minimal risk-free fix for these build failures.

Thus, I've applied this, thanks.
