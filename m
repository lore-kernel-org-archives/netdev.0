From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/5] net: add Hisilicon Network Subsystem MDIO support
Date: Fri, 14 Aug 2015 22:57:28 +0200
Message-ID: <2142879.tTtWetb0nc@wuerfel>
References: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com> <1439548222-231611-4-git-send-email-liguozhu@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Kenneth Lee <liguozhu@hisilicon.com>, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	catalin.marinas@arm.com, will.deacon@arm.com,
	Yisen.Zhuang@huawei.com, davem@davemloft.net,
	paul.gortmaker@windriver.com, dingtianhong@huawei.com,
	zhangfei.gao@linaro.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	huangdaode@hisilicon.com, Kenneth Lee <liguozhu@huawei.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439548222-231611-4-git-send-email-liguozhu@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 14 August 2015 18:30:20 Kenneth Lee wrote:

> +#define MDIO_BASE_ADDR                 0x403C0000

Does not belong in here (and is not used)

> +#define MDIO_COMMAND_REG               0x0
> +#define MDIO_ADDR_REG                  0x4
> +#define MDIO_WDATA_REG                 0x8
> +#define MDIO_RDATA_REG                 0xc
> +#define MDIO_STA_REG                   0x10

These look suspiciously similar to definitions from
drivers/net/ethernet/hisilicon/hip04_mdio.c.

Could the hardware be related? If so, please try to share
the common parts.

> +static inline void mdio_write_reg(void *base, u32 reg, u32 value)
> +{
> +       u8 __iomem *reg_addr = ACCESS_ONCE(base);
> +
> +       writel(value, reg_addr + reg);
> +}
> +
> +#define MDIO_WRITE_REG(a, reg, value) \
> +       mdio_write_reg((a)->vbase, (reg), (value))
> 

Something seems wrong here: why do you have an ACCESS_ONCE() on a
local variable? Doesn't this just make the code less efficient
without providing lockless access to shared variables?

The types are inconsistent here, you should get a warning from
running this through 'make C=1' because of the missing __iomem
annotation of the pointer.

Also, why both a macro and an inline function? Just use an inline
function.

	Arnd
