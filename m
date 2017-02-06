From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next?] hns: avoid stack overflow with CONFIG_KASAN
Date: Mon, 06 Feb 2017 12:03:18 -0500 (EST)
Message-ID: <20170206.120318.1268240226202516488.davem@davemloft.net>
References: <20170203163607.3488037-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com, huangdaode@hisilicon.com,
        yankejian@huawei.com, lisheng011@huawei.com, oulijun@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170203163607.3488037-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri,  3 Feb 2017 17:35:46 +0100

> The use of ACCESS_ONCE() looks like a micro-optimization to force gcc to use
> an indexed load for the register address, but it has an absolutely detrimental
> effect on builds with gcc-5 and CONFIG_KASAN=y, leading to a very likely
> kernel stack overflow aside from very complex object code:
 ...
> This does not seem to happen any more with gcc-7, but removing the ACCESS_ONCE
> seems safe anyway and it avoids a serious issue for some people. I have verified
> that with gcc-5.3.1, the object code we get is better in the new version
> both with and without CONFIG_KASAN, as we no longer allocate a 1344 byte
> stack frame for hns_dsaf_get_regs() but otherwise have practically identical
> object code.
> 
> With gcc-7.0.0, removing ACCESS_ONCE has no effect, the object code is already
> good either way.
> 
> This patch is probably not urgent to get into 4.11 as only KASAN=y builds
> with certain compilers are affected, but I still think it makes sense to
> backport into older kernels.
> 
> Cc: stable@vger.kernel.org
> Fixes: 511e6bc ("net: add Hisilicon Network Subsystem DSAF support")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

This is really terrible for the compiler to do, but what can we do about it.

I'll apply this to 'net' and queue it up for -stable, thanks.
