From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 07/26] net/cycx_drv: replace delay_cycx() with msleep_interruptible()
Date: Wed, 9 Mar 2005 13:18:34 -0800
Message-ID: <20050309211834.GE3685@us.ibm.com>
References: <20050306103258.6FC481E46E@trashy.coderock.org> <422F5BEC.5060909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: domen@coderock.org, netdev@oss.sgi.com, acme@conectiva.com.br,
        janitor@sternwelten.at
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <422F5BEC.5060909@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2005 at 03:26:20PM -0500, Jeff Garzik wrote:
> domen@coderock.org wrote:
> >Use msleep_interruptible() instead of delay_cycx()
> >to guarantee the task delays as expected. Remove the prototype and
> >definition of delay_cycx().
> >
> >Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> >Acked-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
> >Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> >Signed-off-by: Domen Puncer <domen@coderock.org>
> >---
> >
> >
> > kj-domen/drivers/net/wan/cycx_drv.c |   24 ++++++++----------------
> > 1 files changed, 8 insertions(+), 16 deletions(-)
> >
> >diff -puN 
> >drivers/net/wan/cycx_drv.c~msleep_interruptible-drivers_net_wan_cycx_drv 
> >drivers/net/wan/cycx_drv.c
> >--- 
> >kj/drivers/net/wan/cycx_drv.c~msleep_interruptible-drivers_net_wan_cycx_drv	2005-03-05 16:09:34.000000000 +0100
> >+++ kj-domen/drivers/net/wan/cycx_drv.c	2005-03-05 
> >16:09:34.000000000 +0100
> >@@ -56,7 +56,7 @@
> > #include <linux/sched.h>	/* for jiffies, HZ, etc. */
> > #include <linux/cycx_drv.h>	/* API definitions */
> > #include <linux/cycx_cfm.h>	/* CYCX firmware module definitions */
> >-#include <linux/delay.h>	/* udelay */
> >+#include <linux/delay.h>	/* udelay, msleep */
> > #include <asm/io.h>		/* read[wl], write[wl], ioremap, iounmap */
> > 
> > #define	MOD_VERSION	0
> >@@ -74,7 +74,6 @@ static int reset_cyc2x(void __iomem *add
> > static int detect_cyc2x(void __iomem *addr);
> > 
> > /* Miscellaneous functions */
> >-static void delay_cycx(int sec);
> > static int get_option_index(long *optlist, long optval);
> > static u16 checksum(u8 *buf, u32 len);
> > 
> >@@ -259,7 +258,7 @@ static int memory_exists(void __iomem *a
> > 			if (readw(addr + 0x10) == TEST_PATTERN)
> > 				return 1;
> > 
> >-		delay_cycx(1);
> >+		msleep_interruptible(1000);
> 
> use ssleep_interruptible

ssleep_interruptible() doesn't exist; there was much discussion of
whether it should, but then we ran into issues of:

ssleep_interruptible(1) -> msleep_interruptible(1000), which returns,
say, 452, i.e. 452 milliseconds left in sleep. Should
ssleep_interruptible() return 452 and thus take seconds as a parameter
and milliseconds as a return value or should it return 0? or 1? It was
all to confusing for me :)

Thanks,
Nish
