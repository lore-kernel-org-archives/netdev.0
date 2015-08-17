From: Kenneth Lee <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: Re: [PATCH 3/5] net: add Hisilicon Network Subsystem MDIO support
Date: Mon, 17 Aug 2015 17:17:50 +0800
Message-ID: <20150817091750.GA134983@Turing-Arch-b>
References: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com>
 <1439548222-231611-4-git-send-email-liguozhu@hisilicon.com>
 <2142879.tTtWetb0nc@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<pawel.moll-5wv7dgnIgG8@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<catalin.marinas-5wv7dgnIgG8@public.gmane.org>, <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	<Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Kenneth Lee <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2142879.tTtWetb0nc@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks, Arnd, 

You are right. This is the same IP as hip04_mdio.c. We just mis-understand the
hardware design. We will merge them and re-submit the patches.

On Fri, Aug 14, 2015 at 10:57:28PM +0200, Arnd Bergmann wrote:
> On Friday 14 August 2015 18:30:20 Kenneth Lee wrote:
> 
> > +#define MDIO_BASE_ADDR                 0x403C0000
> 
> Does not belong in here (and is not used)
> 
> > +#define MDIO_COMMAND_REG               0x0
> > +#define MDIO_ADDR_REG                  0x4
> > +#define MDIO_WDATA_REG                 0x8
> > +#define MDIO_RDATA_REG                 0xc
> > +#define MDIO_STA_REG                   0x10
> 
> These look suspiciously similar to definitions from
> drivers/net/ethernet/hisilicon/hip04_mdio.c.
> 
> Could the hardware be related? If so, please try to share
> the common parts.
> 
> > +static inline void mdio_write_reg(void *base, u32 reg, u32 value)
> > +{
> > +       u8 __iomem *reg_addr = ACCESS_ONCE(base);
> > +
> > +       writel(value, reg_addr + reg);
> > +}
> > +
> > +#define MDIO_WRITE_REG(a, reg, value) \
> > +       mdio_write_reg((a)->vbase, (reg), (value))
> > 
> 
> Something seems wrong here: why do you have an ACCESS_ONCE() on a
> local variable? Doesn't this just make the code less efficient
> without providing lockless access to shared variables?
> 
> The types are inconsistent here, you should get a warning from
> running this through 'make C=1' because of the missing __iomem
> annotation of the pointer.
> 
> Also, why both a macro and an inline function? Just use an inline
> function.
> 
> 	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
