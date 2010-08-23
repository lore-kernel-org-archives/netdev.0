From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 1/1] posix clocks: introduce syscall for clock tuning.
Date: Mon, 23 Aug 2010 16:46:00 +0200
Message-ID: <201008231646.00357.arnd@arndb.de>
References: <cover.1282550649.git.richard.cochran@omicron.at> <201008231457.26690.arnd@arndb.de> <20100823134330.GM12892@parisc-linux.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100823134330.GM12892-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 23 August 2010, Matthew Wilcox wrote:
> On Mon, Aug 23, 2010 at 02:57:26PM +0200, Arnd Bergmann wrote:
> > > +static inline int common_clock_adj(const clockid_t which_clock, int ppb,
> > > +                              struct timespec *tp)
> > > +{
> > > +   return -EOPNOTSUPP;
> > > +}
> > > +
> > >  static int no_timer_create(struct k_itimer *new_timer)
> > >  {
> > >     return -EOPNOTSUPP;
> > 
> > So we already return -EOPNOTSUPP in some cases? The man page does not document this.
> > I wonder if we should change that to -EINVAL as well.
> 
> ENOTTY is the usual errno for "inappropriate ioctl for device".  Due to
> the way this patch has been chopped up, I can't tell if that's what is
> intended here.

It's for the CLOCK_* syscall family, which I think is different enough from
an ioctl that ENOTTY makes no sense.

The documented return values of timer_create() are EAGAIN, EINVAL and
ENOMEM.

	Arnd
