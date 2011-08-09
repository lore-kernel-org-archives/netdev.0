From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [RFC 4/4] [powerpc] Add flexcan device support for p1010rdb.
Date: Tue, 9 Aug 2011 07:04:46 -0500
Message-ID: <20110809120446.GP4926@sgi.com>
References: <1312869313-22434-1-git-send-email-holt@sgi.com>
	<1312869313-22434-5-git-send-email-holt@sgi.com>
	<20110809063319.GK4926@sgi.com> <4E40DDA5.1050004@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E40DDA5.1050004-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 09, 2011 at 09:11:33AM +0200, Wolfgang Grandegger wrote:
> On 08/09/2011 08:33 AM, Robin Holt wrote:
> > Argh.  I sent an earlier (non-working) version of this patch.  Here is
> > the correct one.
> 
> Please always resend the complete series of patches with an incremented
> version number. Furthermore, this is not an RFC any more. A prefix
> similar to [PATCH nfsl_get_sys_freq() et-next-2.6 v2] would be perfect.
> 
> > I added a clock source for the p1010rdb so the flexcan driver
> > could find its clock frequency.
> > 
> > Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> > To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
> > To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
> > To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> > Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> > Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> > Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
> > ---
> >  arch/powerpc/platforms/85xx/Kconfig    |    6 +++
> >  arch/powerpc/platforms/85xx/Makefile   |    1 +
> >  arch/powerpc/platforms/85xx/clock.c    |   59 ++++++++++++++++++++++++++++++++
> >  arch/powerpc/platforms/85xx/p1010rdb.c |   10 +++++
> >  4 files changed, 76 insertions(+), 0 deletions(-)
> >  create mode 100644 arch/powerpc/platforms/85xx/clock.c
> > 
> > diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
> > index 498534c..ed4cf92 100644
> > --- a/arch/powerpc/platforms/85xx/Kconfig
> > +++ b/arch/powerpc/platforms/85xx/Kconfig
> > @@ -26,6 +26,10 @@ config MPC8560_ADS
> >  	help
> >  	  This option enables support for the MPC 8560 ADS board
> >  
> > +config 85xx_HAVE_CAN_FLEXCAN
> > +	bool
> > +	select HAVE_CAN_FLEXCAN if NET && CAN
> > +
> 
> Why do you need that? More below...

Happily removed.

> >  config MPC85xx_CDS
> >  	bool "Freescale MPC85xx CDS"
> >  	select DEFAULT_UIMAGE
> > @@ -70,6 +74,8 @@ config MPC85xx_RDB
> >  config P1010_RDB
> >  	bool "Freescale P1010RDB"
> >  	select DEFAULT_UIMAGE
> > +	select 85xx_HAVE_CAN_FLEXCAN
> > +	select PPC_CLOCK if CAN_FLEXCAN
> 
> 	select HAVE_CAN_FLEXCAN
> 	select PPC_CLOCK
> 
> Should just be fine, or have I missed something.

If I don't have the if NET && CAN, then 'make savedefconfig' will
complain.  Otherwise, removed 85xx_HAVE_CAN_FLEXCAN.

> >  	help
> >  	  This option enables support for the MPC85xx RDB (P1010 RDB) board
> >  
> > diff --git a/arch/powerpc/platforms/85xx/Makefile b/arch/powerpc/platforms/85xx/Makefile
> > index a971b32..64ad7a4 100644
> > --- a/arch/powerpc/platforms/85xx/Makefile
> > +++ b/arch/powerpc/platforms/85xx/Makefile
> > @@ -11,6 +11,7 @@ obj-$(CONFIG_MPC85xx_DS)  += mpc85xx_ds.o
> >  obj-$(CONFIG_MPC85xx_MDS) += mpc85xx_mds.o
> >  obj-$(CONFIG_MPC85xx_RDB) += mpc85xx_rdb.o
> >  obj-$(CONFIG_P1010_RDB)   += p1010rdb.o
> > +obj-$(CONFIG_PPC_CLOCK)   += clock.o
> 
> I would put that to the beginning or before the board settings.

Done.

> >  obj-$(CONFIG_P1022_DS)    += p1022_ds.o
> >  obj-$(CONFIG_P1023_RDS)   += p1023_rds.o
> >  obj-$(CONFIG_P2040_RDB)   += p2040_rdb.o corenet_ds.o
> > diff --git a/arch/powerpc/platforms/85xx/clock.c b/arch/powerpc/platforms/85xx/clock.c
> > new file mode 100644
> > index 0000000..a25cbf3
> > --- /dev/null
> > +++ b/arch/powerpc/platforms/85xx/clock.c
> > @@ -0,0 +1,59 @@
> > +
> > +#include <linux/device.h>
> > +#include <linux/err.h>
> > +
> > +#include <asm/clk_interface.h>
> > +
> > +#include <sysdev/fsl_soc.h>
> > +
> > +/*
> > + * p1010rdb needs to provide a clock source for the flexcan driver.
> > + */
> > +struct clk {
> > +	unsigned long rate;
> > +} p1010_rdb_system_clock;
> > +
> > +static struct clk *p1010_rdb_clk_get(struct device *dev, const char *id)
> > +{
> > +	const char *dev_init_name;
> > +
> > +	if (!dev)
> > +		return ERR_PTR(-ENOENT);
> > +
> > +	/*
> > +	 * The can devices are named ffe1c000.can0 and ffe1d000.can1 on
> > +	 * the p1010rdb.  Check for the "can" portion of that name before
> > +	 * returning a clock source.
> > +	 */
> > +	dev_init_name = dev_name(dev);
> > +	if (strlen(dev_init_name) != 13)
> > +		return ERR_PTR(-ENOENT);
> > +	dev_init_name += 9;
> > +	if (strncmp(dev_init_name, "can", 3))
> > +		return ERR_PTR(-ENOENT);
> 
> What's that good for? Also it's wrong to rely on the special name of the
> node. I think it can be removed.

Removed.

> 
> > +	return &p1010_rdb_system_clock;
> 
> Just returning fsl_get_sys_freq() here would already be fine. I'm also
> missing the factor of two here:
> 
>         return fsl_get_sys_freq() / 2; ????

If we were going that route, I would return NULL here and do that
return on the clk_get_rate() call, correct?  I just tested with that
and it worked.

> > +}
> > +
> > +static void p1010_rdb_clk_put(struct clk *clk)
> > +{
> > +	return;
> > +}
> > +
> > +static unsigned long p1010_rdb_clk_get_rate(struct clk *clk)
> > +{
> > +	return clk->rate;
> > +}
> > +
> > +static struct clk_interface p1010_rdb_clk_functions = {
> > +	.clk_get		= p1010_rdb_clk_get,
> > +	.clk_get_rate		= p1010_rdb_clk_get_rate,
> > +	.clk_put		= p1010_rdb_clk_put,
> > +};
> > +
> > +void __init p1010_rdb_clk_init(void)
> > +{
> > +	p1010_rdb_system_clock.rate = fsl_get_sys_freq();
> 
> > +	clk_functions = p1010_rdb_clk_functions;
> > +}
> 
> The name is too specific. The idea is that the interface could be used
> for other 85xx processors as well, not only the p1010. The prefix
> "mpc85xx_" instead of "p1010_rdb" seems more appropriate to me.

Done.

> 
> > diff --git a/arch/powerpc/platforms/85xx/p1010rdb.c b/arch/powerpc/platforms/85xx/p1010rdb.c
> > index d7387fa..d0afbf9 100644
> > --- a/arch/powerpc/platforms/85xx/p1010rdb.c
> > +++ b/arch/powerpc/platforms/85xx/p1010rdb.c
> > @@ -81,6 +81,15 @@ static void __init p1010_rdb_setup_arch(void)
> >  	printk(KERN_INFO "P1010 RDB board from Freescale Semiconductor\n");
> >  }
> >  
> > +extern void p1010_rdb_clk_init(void);
> > +
> > +static void __init p1010_rdb_init(void)
> > +{
> > +#ifdef CONFIG_PPC_CLOCK
> > +	p1010_rdb_clk_init();
> > +#endif
> > +}
> 
> The #ifdef's are not needed if CONFIG_PPC_CLOCK is selected in the Kconfig.

Done.

> 
> >  static struct of_device_id __initdata p1010rdb_ids[] = {
> >  	{ .type = "soc", },
> >  	{ .compatible = "soc", },
> > @@ -111,6 +120,7 @@ define_machine(p1010_rdb) {
> >  	.name			= "P1010 RDB",
> >  	.probe			= p1010_rdb_probe,
> >  	.setup_arch		= p1010_rdb_setup_arch,
> > +	.init			= p1010_rdb_init,
> >  	.init_IRQ		= p1010_rdb_pic_init,
> >  #ifdef CONFIG_PCI
> >  	.pcibios_fixup_bus	= fsl_pcibios_fixup_bus,

Thank you very much for your patience with me,
Robin
