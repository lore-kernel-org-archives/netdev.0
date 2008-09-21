From: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware
 restart.
Date: Sun, 21 Sep 2008 13:27:53 -0700
Message-ID: <20080921132753.5689b564@infradead.org>
References: <20080921172316.GA6306@2ka.mipt.ru>
	<20080921110422.1d010b96@infradead.org>
	<20080921182835.GA11473@2ka.mipt.ru>
	<20080921113513.16677c4e@infradead.org>
	<20080921190050.GA20484@2ka.mipt.ru>
	<1222024444.3023.53.camel@johannes.berg>
	<20080921193809.GA8735@2ka.mipt.ru>
	<20080921124332.67ddc13a@infradead.org>
	<20080921202057.GB25052@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080921202057.GB25052-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Sep 2008 00:20:57 +0400
Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org> wrote:

> On Sun, Sep 21, 2008 at 12:43:32PM -0700, Arjan van de Ven
> (arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org) wrote:
> > > @@ -3174,6 +3176,10 @@ static void ipw2100_irq_tasklet(struct
> > > ipw2100_priv *priv) if (inta & IPW2100_INTA_FATAL_ERROR) {
> > >  		printk(KERN_WARNING DRV_NAME
> > >  		       ": Fatal interrupt. Scheduling firmware
> > > restart.\n");
> > > +		WARN_ON(1);
> > > +
> > > +		BUG_ON(ipw2100_max_fatal_ints-- <= 0);
> > 
> > BUG_ON in interrupt context is just extremely hostile, since it
> > means the box is dead.
> >
> > also I would suggest using WARN_ON_ONCE() 
> 
> Well, I actually wanted to have a bug there because of it, but now I
> think that annoying repeated warning is enough to bring attention to
> the problem by putting bug information into some magic special place
> called kerneloops collection.

are you more interested in bringing attention than finding something
that makes the driver work ? I sort of am getting that impression and
I'd be disappointed if that is the case.


> 
> Consider for inclusing for the upcoming kernel to get wider
> notifications. Yes, it is not a bugfix, I know.

still more complex than needed; a WARN_ON_ONCE() will be enough.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
