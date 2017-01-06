From: =?utf-8?B?TWljaGHFgiBLxJlwaWXFhA==?= <kernel-ePNcKBjznIDVItvQsEIGlw@public.gmane.org>
Subject: Re: [PATCH v4] rfkill: Add rfkill-any LED trigger
Date: Fri, 6 Jan 2017 20:20:27 +0100
Message-ID: <20170106192027.GA756@kmp-mobile.hq.kempniu.pl>
References: <20170106060747.6162-1-kernel@kempniu.pl>
 <1483705333.4089.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        =?utf-8?B?0JzQuNGF0LDQuNC7INCa0YDQuNC90LrQuNC9?=
        <krinkin.m.u-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1483705333.4089.6.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Fri, 2017-01-06 at 07:07 +0100, Michał Kępień wrote:
> > Add a new "global" (i.e. not per-rfkill device) LED trigger, rfkill-
> > any,
> > which may be useful on laptops with a single "radio LED" and multiple
> > radio transmitters.  The trigger is meant to turn a LED on whenever
> > there is at least one radio transmitter active and turn it off
> > otherwise.
> > 
> > Signed-off-by: Michał Kępień <kernel-ePNcKBjznIDVItvQsEIGlw@public.gmane.org>
> > ---
> > Changes from v3:
> > 
> >   - Revert introducing a new bitfield and instead defer LED event
> > firing
> >     to a work queue to prevent conditional locking and ensure the
> >     trigger can really be used from any context.  This also voids the
> >     need to take rfkill_global_mutex before calling
> > rfkill_set_block()
> >     in rfkill_resume().
> 
> Looks better, but
> 
> > +static struct work_struct rfkill_any_work;
> 
> At least on module exit you need to cancel this work.

It is cancelled in rfkill_any_led_trigger_unregister().  It seemed
fitting to do it this way as rfkill_any_work is initialized in
rfkill_any_led_trigger_register().  And if CONFIG_RFKILL_LEDS=n,
rfkill_any_work is neither initialized nor scheduled, so we should be
good as well.  Am I missing something?

-- 
Best regards,
Michał Kępień
