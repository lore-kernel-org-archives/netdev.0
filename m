From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v2, -net] cpsw/netcp: work around reverse cpts
 dependency
Date: Wed, 22 Mar 2017 10:57:03 -0700 (PDT)
Message-ID: <20170322.105703.567983727621129027.davem@davemloft.net>
References: <20170320085339.1033988-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grygorii.strashko@ti.com, tglx@linutronix.de,
        richardcochran@gmail.com, u.kleine-koenig@pengutronix.de,
        nicolas.pitre@linaro.org, w-kwok2@ti.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320085339.1033988-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 20 Mar 2017 09:52:50 +0100

> The dependency is reversed: cpsw and netcp call into cpts,
> but cpts depends on the other two in Kconfig. This can lead
> to cpts being a loadable module and its callers built-in:
> 
> drivers/net/ethernet/ti/cpsw.o: In function `cpsw_remove':
> cpsw.c:(.text.cpsw_remove+0xd0): undefined reference to `cpts_release'
> drivers/net/ethernet/ti/cpsw.o: In function `cpsw_rx_handler':
> cpsw.c:(.text.cpsw_rx_handler+0x2dc): undefined reference to `cpts_rx_timestamp'
> drivers/net/ethernet/ti/cpsw.o: In function `cpsw_tx_handler':
> cpsw.c:(.text.cpsw_tx_handler+0x7c): undefined reference to `cpts_tx_timestamp'
> drivers/net/ethernet/ti/cpsw.o: In function `cpsw_ndo_stop':
> 
> As a workaround, I'm introducing another Kconfig symbol to
> control the compilation of cpts, while making the actual
> module controlled by a silent symbol that is =y when necessary.
> 
> Fixes: 6246168b4a38 ("net: ethernet: ti: netcp: add support of cpts")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
> v1: Originally submitted on Dec 16, still needed for v4.10 and v4.11-rc2
> v2: change the symbol names to keep existing defconfigs working

I've applied these two cpsw fixes, thanks Arnd.
