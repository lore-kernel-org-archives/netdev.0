From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ethernet/arc/arc_emac - Add new driver
Date: Fri, 07 Jun 2013 14:13:14 +0200
Message-ID: <2468036.im0srnzmHT@wuerfel>
References: <1370348510-23754-1-git-send-email-abrodkin@synopsys.com> <1505761.5DsauZd6eq@wuerfel> <4881796E12491D4BB15146FE0209CE643F5C77EC@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F5C77EC@DE02WEMBXB.internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 07 June 2013 10:42:28 Alexey Brodkin wrote:
> On 06/07/2013 12:47 PM, Arnd Bergmann wrote:

> > I wonder if it would be better to name the directory "synopsys" or
> > "designware" rather than "arc" now. Is there a chance that the same
> > controller is used on non-arc CPUs?
> 
> The thing is - "arc_emac" is a custom ARC's (that was implemented before 
> acquisition of ARC by Synopsys) IP (it's not an IC - just a part of CPU) 
> Ethernet controller that only exists in some legacy FPGA boards we 
> (ex-ARC and our customers) still use a lot in development process.
> 
> Synopsys itself doesn't actively sell this device so there's no point in 
> putting ARC EMAC into Synopsys folder.
> 
> And indeed we don't expect this device to be used with non-ARC CPU's.
> 
> I didn't add dependency on ARC in Kconfig just because I wanted to leave 
> an ability to build this driver on x86 machine. I thought this is 
> important requirement - allow anybody to at least build this driver to 
> make sure it builds and doesn't cause tons of warnings to appear.
> 
> If it's totally fine to add dependency on ARC - then it would be even 
> easier for me - refer to the next block of comments.

No, I think making it generally available for all architectures is better.

> >> +static int arc_emac_probe(struct platform_device *pdev)
> >> +{
> >> +	struct net_device *net_dev;
> >> +	struct arc_emac_priv *priv;
> >> +	int err;
> >> +	unsigned int clock_frequency;
> >> +	unsigned int id;
> >> +	struct resource res_regs;
> >> +#ifdef CONFIG_OF_IRQ
> >> +	struct resource res_irq;
> >> +#endif
> >> +	const char *mac_addr = NULL;
> >
> > Please remove the #ifdef here. The driver does not work without this
> > anyway, so better make it 'depend on OF_IRQ' in Kconfig.
> 
> As stated above I wanted to make it possible to compile on x86.
> And for this I needed to:
> 1. Add explicit mentions of "linux/platform_device.h" because with 
> existence of OF "linux/of_platform.h" has "linux/platform_device.h" 
> included internally.
> 2. Enclose "of_irq_to_resource" and "of_get_mac_address" in ifdefs 
> because neither of them has a stub for non-OF situation.

But you can enable CONFIG_OF on x86. An allmodconfig build should
still enable this driver. The #ifdefs are generally considered ugly,
and there is no point adding them when the driver clearly wouldn't
work on any architecture without them even if that hardware was
available.

> So if I may depend on ARC then I'm sure OF is selected and no need to worry.
> Otherwise do I need to add stubs for "of_irq_to_resource" and 
> "of_get_mac_address" somewhere in "of/of_xxx.h"?

We are currently discussing those changes to the header files elsewhere.
I think with a dependency on CONFIG_OF_IRQ and other symbols you need,
you get the best compromise of the various requirements.

	Arnd
