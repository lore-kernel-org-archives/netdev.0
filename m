From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 02/12] can: c_can: Fix hardware raminit function
Date: Wed, 19 Mar 2014 10:22:27 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403191016280.18573@ionos.tec.linutronix.de>
References: <20140318171007.528610837@linutronix.de> <20140318171126.720944558@linutronix.de> <532892BC.7080406@pengutronix.de> <alpine.DEB.2.02.1403182313110.18573@ionos.tec.linutronix.de> <53293B31.2060406@hartkopp.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	LKML <linux-kernel@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53293B31.2060406@hartkopp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Mar 2014, Oliver Hartkopp wrote:
> On 18.03.2014 23:15, Thomas Gleixner wrote:
> > On Tue, 18 Mar 2014, Marc Kleine-Budde wrote:
> >> On 03/18/2014 06:19 PM, Thomas Gleixner wrote:
> >>> +static void c_can_hw_raminit_wait(const struct c_can_priv *priv, u32 mask,
> >>> +				  u32 val)
> >>> +{
> >>> +	/* We look only at the bits of our instance. */
> >>> +	val &= mask;
> >>> +	while ((readl(priv->raminit_ctrlreg) & mask) != val)
> >>> +		udelay(1);
> >>
> >> Do we have to add a timeout here, or is it "safe" to have a potential
> >> endless loop here? As you have probably tortured the hardware and driver
> >> a lot (or have been tortured by them), I assume you would have added a
> >> timeout check if you had seen a lockup here.
> > 
> > I haven't seen any failure on that. We could add a timeout for
> > paranoia reasons. I'm quite sure that the raminit works as advertised
> > when we do it the right way. The only way to wreckage it so far is by
> > not waiting for it to complete.
> 
> As long as it is 100% guaranteed that we
> 
> 1. really work on a valid C_CAN core
> 2. this CAN controller can not be unplugged
> 
> not adding a timeout would be ok.

The raminit port is a D_CAN specific thing. But yeah, adding a timeout
wouldn't hurt at all.

Though the driver is incomplete anyway as not all D_CAN incarnations
use the raminit port. There is another way to do that via the CFR
register, which is not implemented in the driver.

It seems the chip integrator can chose between raminit port and CFR.

Thanks,

	tglx
