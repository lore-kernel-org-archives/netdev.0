From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH V2 01/14] clk: add helper functions clk_prepare_enable
 and clk_disable_unprepare
Date: Fri, 11 Nov 2011 12:56:44 +0100
Message-ID: <20111111115644.GT16886@pengutronix.de>
References: <1320973829-4388-1-git-send-email-richard.zhao@linaro.org>
 <1320973829-4388-2-git-send-email-richard.zhao@linaro.org>
 <20111111084950.GH16886@pengutronix.de>
 <20111111090546.GC14617@b20223-02.ap.freescale.net>
 <20111111091556.GI16886@pengutronix.de>
 <20111111102727.GC12913@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Zhao <richard.zhao@linaro.org>,
	amit.kucheria@canonical.com, kernel@pengutronix.de,
	netdev@vger.kernel.org, linux-mmc@vger.kernel.org,
	ben-linux@fluff.org, eric.miao@linaro.org,
	linux-i2c@vger.kernel.org, linux-serial@vger.kernel.org,
	cjb@laptop.org, linux-arm-kernel@lists.infradead.org,
	alan@linux.intel.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-mmc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111111102727.GC12913@n2100.arm.linux.org.uk>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2011 at 10:27:27AM +0000, Russell King - ARM Linux wrote:
> On Fri, Nov 11, 2011 at 10:15:56AM +0100, Sascha Hauer wrote:
> > On Fri, Nov 11, 2011 at 05:05:47PM +0800, Richard Zhao wrote:
> > > {
> > > 	int ret;
> > > 
> > > 	ret = clk_prepare(clk);
> > > 	if (ret)
> > > 		return ret;
> > > 	ret = clk_enable(clk);
> > > 	if (ret)
> > > 		clk_unprepare(clk);
> > > 	return ret;
> > 
> > Yes, looks good.
> 
> While this looks like a nice easy solution for converting existing
> drivers, I'd suggest thinking about this a little more...
> 
> I would suggest some thought is given to the placement of clk_enable()
> and clk_disable() when adding clk_prepare(), especially if your existing
> clk_enable() function can only be called from non-atomic contexts.
> 
> Obviously, the transition path needs to be along these lines:
> 
> 1. add clk_prepare() to drivers
> 2. implement clk_prepare() and make clk_enable() callable from non-atomic
>    contexts
> 3. move clk_enable() in drivers to places it can be called from non-atomic
>    contexts to achieve greater power savings (maybe via the runtime pm)
> 
> and where a driver is shared between different sub-architectures which
> have non-atomic clk_enable()s, (3) can only happen when all those sub-
> architectures have been updated to step (2).

The drivers changed here all do clk_prepare/enable in their probe
function. I agree that this clk_prepare_enable patch gives kind of
wrong motivation to just use this function and to forget about
potential power savings with proper integration of clk_prepare/enable.
I think though that it will take a long time until all drivers really
do this no matter if we have such a helper or not. I think that in the
meantime it's better to have a little helper than to clobber the probe
code with additional error handling.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
