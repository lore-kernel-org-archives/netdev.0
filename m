From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] amd-xgbe: use __maybe_unused to hide pm
 functions
Date: Wed, 09 Nov 2016 20:32:51 -0500 (EST)
Message-ID: <20161109.203251.2242759501432326877.davem@davemloft.net>
References: <20161108133802.1716319-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161108133802.1716319-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue,  8 Nov 2016 14:37:32 +0100

> The amd-xgbe ethernet driver hides its suspend/resume functions
> in #ifdef CONFIG_PM, but uses SIMPLE_DEV_PM_OPS() to make the
> reference conditional on CONFIG_PM_SLEEP, which results in a
> warning when PM_SLEEP is not set but PM is:
> 
> drivers/net/ethernet/amd/xgbe/xgbe-platform.c:553:12: error: 'xgbe_platform_resume' defined but not used [-Werror=unused-function]
> drivers/net/ethernet/amd/xgbe/xgbe-platform.c:533:12: error: 'xgbe_platform_suspend' defined but not used [-Werror=unused-function]
> 
> This removes the incorrect #ifdef and instead uses a __maybe_unused
> annotation to let the compiler know it can silently drop
> the function definition.
> 
> Fixes: bd8255d8ba35 ("amd-xgbe: Prepare for supporting PCI devices")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> I originally submitted this when in March 2016, but the patch has not
> yet made it upstream, and the file contents have moved around so
> the old patch no longer applied so I'm resending the rebased version
> now.

By and large, drivers handle this by using a CONFIG_PM_SLEEP ifdef.

Unless you can make an extremely convincing argument why not to do
so here, I'd like you to handle it that way instead.

Thanks.
