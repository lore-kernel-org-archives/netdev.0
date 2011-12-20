From: Richard Zhao <richard.zhao@freescale.com>
Subject: Re: [PATCH V3 10/14] ARM: mxs: add clk_prepare/clk_unprepare
Date: Tue, 20 Dec 2011 08:56:34 +0800
Message-ID: <20111220005633.GC15863@b20223-02.ap.freescale.net>
References: <1321008637-19999-1-git-send-email-richard.zhao@linaro.org>
 <1321008637-19999-11-git-send-email-richard.zhao@linaro.org>
 <201112192321.41560.marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-arm-kernel@lists.infradead.org>,
	<amit.kucheria@canonical.com>, <linux@arm.linux.org.uk>,
	<kernel@pengutronix.de>, <netdev@vger.kernel.org>,
	<linux-mmc@vger.kernel.org>, <eric.miao@linaro.org>,
	<linux-i2c@vger.kernel.org>, <linux-serial@vger.kernel.org>,
	<cjb@laptop.org>, Fabio Estevam <festevam@gmail.com>,
	Richard Zhao <richard.zhao@linaro.org>, <ben-linux@fluff.org>,
	<alan@linux.intel.com>
To: Marek Vasut <marek.vasut@gmail.com>
Return-path: <linux-serial-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201112192321.41560.marek.vasut@gmail.com>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2011 at 11:21:41PM +0100, Marek Vasut wrote:
> > Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
> > ---
> >  arch/arm/mach-mxs/system.c |    2 +-
> >  arch/arm/mach-mxs/timer.c  |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/arch/arm/mach-mxs/system.c b/arch/arm/mach-mxs/system.c
> > index 20ec3bd..9760a12 100644
> > --- a/arch/arm/mach-mxs/system.c
> > +++ b/arch/arm/mach-mxs/system.c
> > @@ -66,7 +66,7 @@ static int __init mxs_arch_reset_init(void)
> > 
> >  	clk = clk_get_sys("rtc", NULL);
> >  	if (!IS_ERR(clk))
> > -		clk_enable(clk);
> > +		clk_prepare_enable(clk);
> > 
> >  	return 0;
> >  }
> > diff --git a/arch/arm/mach-mxs/timer.c b/arch/arm/mach-mxs/timer.c
> > index cace0d2..564a632 100644
> > --- a/arch/arm/mach-mxs/timer.c
> > +++ b/arch/arm/mach-mxs/timer.c
> > @@ -245,7 +245,7 @@ static int __init mxs_clocksource_init(struct clk
> > *timer_clk)
> > 
> >  void __init mxs_timer_init(struct clk *timer_clk, int irq)
> >  {
> > -	clk_enable(timer_clk);
> > +	clk_prepare_enable(timer_clk);
> > 
> >  	/*
> >  	 * Initialize timers to a known state
> 
> Hi Richard,
> 
> I just came across this, will this also help solve the mxs problem with mutex 
> lock begin done in atomic context in clk_enable/disable()?
No, It's for converting to generic clock framwork.
You can look at Mike's generic clock patches. clk_hw_ops.enable/disable
definitely can not sleep.
On register side, there' two way to protect register:
 - use a global spin lock
 - only use spin lock wherever gate register share the same one with
   other non-gate register.

Thanks
Richard
> 
> M
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

