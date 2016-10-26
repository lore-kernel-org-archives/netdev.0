From: Scott Wood <oss@buserror.net>
Subject: Re: [v12, 5/8] soc: fsl: add GUTS driver for QorIQ platforms
Date: Wed, 26 Oct 2016 12:06:06 -0500
Message-ID: <1477501566.6812.9.camel@buserror.net>
References: <1474441040-11946-1-git-send-email-yangbo.lu@nxp.com>
         <1474441040-11946-6-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linux-clk@vger.kernel.org, linux-i2c@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org,
        Mark Rutland <mark.rutland@arm.com>,
        Rob Herring <robh+dt@kernel.org>,
        Russell King <linux@arm.linux.org.uk>,
        Jochen Friedrich <jochen@scram.de>,
        Joerg Roedel <joro@8bytes.org>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        Bhupesh Sharma <bhupesh.sharma@freescale.com>,
        Qiang Zhao <qiang.zhao@nxp.com>,
        Kumar Gala <galak@codeaurora.org>,
        Santosh Shilimkar <ssantosh@kernel.org>,
        Leo Li <leoyang.li@nxp.com>, Xiaobo Xie <xiaobo.xie@nxp.com>,
        Minghuan Lian <minghuan.lian@nxp.com>
To: Yangbo Lu <yangbo.lu@nxp.com>, linux-mmc@vger.kernel.org,
        ulf.hansson@linaro.org, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474441040-11946-6-git-send-email-yangbo.lu@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-09-21 at 14:57 +0800, Yangbo Lu wrote:
> diff --git a/drivers/soc/fsl/Kconfig b/drivers/soc/fsl/Kconfig
> new file mode 100644
> index 0000000..b99764c
> --- /dev/null
> +++ b/drivers/soc/fsl/Kconfig
> @@ -0,0 +1,19 @@
> +#
> +# Freescale SOC drivers
> +#
> +
> +source "drivers/soc/fsl/qe/Kconfig"
> +
> +config FSL_GUTS
> +	bool "Freescale QorIQ GUTS driver"
> +	select SOC_BUS
> +	help
> +	  The global utilities block controls power management, I/O device
> +	  enabling, power-onreset(POR) configuration monitoring, alternate
> +	  function selection for multiplexed signals,and clock control.
> +	  This driver is to manage and access global utilities block.
> +	  Initially only reading SVR and registering soc device are
> supported.
> +	  Other guts accesses, such as reading RCW, should eventually be
> moved
> +	  into this driver as well.
> +
> +	  If you want GUTS driver support, you should say Y here.

This is user-enablable without dependencies, which means it will break some
randconfigs.  If this is to be enabled via select then remove the text after
"bool".

> +/* SoC die attribute definition for QorIQ platform */
> +static const struct fsl_soc_die_attr fsl_soc_die[] = {
> +#ifdef CONFIG_PPC
> +	/*
> +	 * Power Architecture-based SoCs T Series
> +	 */
> +
> +	/* Die: T4240, SoC: T4240/T4160/T4080 */
> +	{ .die		= "T4240",
> +	  .svr		= 0x82400000,
> +	  .mask		= 0xfff00000,
> +	},
> +	/* Die: T1040, SoC: T1040/T1020/T1042/T1022 */
> +	{ .die		= "T1040",
> +	  .svr		= 0x85200000,
> +	  .mask		= 0xfff00000,
> +	},
> +	/* Die: T2080, SoC: T2080/T2081 */
> +	{ .die		= "T2080",
> +	  .svr		= 0x85300000,
> +	  .mask		= 0xfff00000,
> +	},
> +	/* Die: T1024, SoC: T1024/T1014/T1023/T1013 */
> +	{ .die		= "T1024",
> +	  .svr		= 0x85400000,
> +	  .mask		= 0xfff00000,
> +	},
> +#endif /* CONFIG_PPC */
> +#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_ARCH_LAYERSCAPE)

Will this driver ever be probed on MXC?  Why do we need these ifdefs at all?


> +	/*
> +	 * ARM-based SoCs LS Series
> +	 */
> +
> +	/* Die: LS1043A, SoC: LS1043A/LS1023A */
> +	{ .die		= "LS1043A",
> +	  .svr		= 0x87920000,
> +	  .mask		= 0xffff0000,
> +	},
> +	/* Die: LS2080A, SoC: LS2080A/LS2040A/LS2085A */
> +	{ .die		= "LS2080A",
> +	  .svr		= 0x87010000,
> +	  .mask		= 0xff3f0000,
> +	},
> +	/* Die: LS1088A, SoC: LS1088A/LS1048A/LS1084A/LS1044A */
> +	{ .die		= "LS1088A",
> +	  .svr		= 0x87030000,
> +	  .mask		= 0xff3f0000,
> +	},
> +	/* Die: LS1012A, SoC: LS1012A */
> +	{ .die		= "LS1012A",
> +	  .svr		= 0x87040000,
> +	  .mask		= 0xffff0000,
> +	},
> +	/* Die: LS1046A, SoC: LS1046A/LS1026A */
> +	{ .die		= "LS1046A",
> +	  .svr		= 0x87070000,
> +	  .mask		= 0xffff0000,
> +	},
> +	/* Die: LS2088A, SoC: LS2088A/LS2048A/LS2084A/LS2044A */
> +	{ .die		= "LS2088A",
> +	  .svr		= 0x87090000,
> +	  .mask		= 0xff3f0000,
> +	},
> +	/* Die: LS1021A, SoC: LS1021A/LS1020A/LS1022A
> +	 * Note: Put this die at the end in cause of incorrect
> identification
> +	 */
> +	{ .die		= "LS1021A",
> +	  .svr		= 0x87000000,
> +	  .mask		= 0xfff00000,
> +	},
> +#endif /* CONFIG_ARCH_MXC || CONFIG_ARCH_LAYERSCAPE */

Instead of relying on ordering, add more bits to the mask so that there's no
overlap.  I think 0xfff70000 would work.

> +out:
> +	kfree(soc_dev_attr.machine);
> +	kfree(soc_dev_attr.family);
> +	kfree(soc_dev_attr.soc_id);
> +	kfree(soc_dev_attr.revision);
> +	iounmap(guts->regs);
> +out_free:
> +	kfree(guts);
> +	return ret;
> +}

Please use devm.

-Scott
