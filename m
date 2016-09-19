From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 1/2] ptp_clock: allow for it to be optional
Date: Mon, 19 Sep 2016 10:31:13 -0700
Message-ID: <20160919173112.tpexkd44ggorg7ww@x>
References: <1474257070-4255-1-git-send-email-nicolas.pitre@linaro.org>
 <1474257070-4255-2-git-send-email-nicolas.pitre@linaro.org>
 <20160919142553.3fb682ba@griffin>
 <alpine.LFD.2.20.1609190942230.9311@knanqh.ubzr>
 <20160919190415.26bd9343@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Richard Cochran <richardcochran@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kbuild@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160919190415.26bd9343@griffin>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2016 at 07:04:15PM +0200, Jiri Benc wrote:
> On Mon, 19 Sep 2016 10:10:21 -0400 (EDT), Nicolas Pitre wrote:
> > --- a/include/linux/ptp_clock_kernel.h
> > +++ b/include/linux/ptp_clock_kernel.h
> > @@ -207,7 +207,16 @@ int ptp_find_pin(struct ptp_clock *ptp,
> >  #else
> >  static inline struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
> >  						   struct device *parent)
> > -{ return NULL; }
> > +{
> > +	if (IS_MODULE(CONFIG_PTP_1588_CLOCK)) {
> > +		pr_warn("%s is built-in while PTP clock subsystem is modular, "
> > +			"PTP clock ignored\n", KBUILD_MODNAME);
> > +	} else {
> > +		pr_warn("ignoring PTP clock from %s as PTP clock subsystem "
> > +			"is configured out\n", KBUILD_MODNAME);
> > +	}
> > +	return NULL;
> > +}
> 
> I think the else part is not needed. If PTP is disabled, it is
> disabled, nobody should be surprised by that. Looks good otherwise.

This works, and it should compile away to nothing in the normal case.
But it does seem unfortunate that this can't happen at build time via
Kconfig.  CCing linux-kbuild in case someone has an idea for how to fix
this.
