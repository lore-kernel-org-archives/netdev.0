From: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Sun, 18 Jan 2009 11:10:29 +0100
Message-ID: <20090118101029.GA31461@uranus.ravnborg.org>
References: <1232223441.3966.22.camel@localhost.localdomain> <1232228261.27094.0.camel@macbook.infradead.org> <20090117221932.GA4956@uranus.ravnborg.org> <20090118091300.GA24849@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	x86 maintainers <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, tiwai-l3A5Bk7waGM@public.gmane.org,
	mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090118091300.GA24849-X9Un+BFzKDI@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 18, 2009 at 10:13:00AM +0100, Ingo Molnar wrote:
> 
> * Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org> wrote:
> 
> > On Sun, Jan 18, 2009 at 08:37:41AM +1100, David Woodhouse wrote:
> > > On Sun, 2009-01-18 at 01:47 +0530, Jaswinder Singh Rajput wrote:
> > > > --- a/include/linux/dvb/audio.h
> > > > +++ b/include/linux/dvb/audio.h
> > > > @@ -24,9 +24,8 @@
> > > >  #ifndef _DVBAUDIO_H_
> > > >  #define _DVBAUDIO_H_
> > > >  
> > > > -#ifdef __KERNEL__
> > > >  #include <linux/types.h>
> > > > -#else
> > > > +#ifndef __KERNEL__
> > > >  #include <stdint.h>
> > > >  #endif
> > > >  
> > > 
> > > That patch looks wrong, and unnecessary. It was fine before.
> > Nope - include/linux/dvb/audio.h failed to include linux/types.h
> > despite the fact that is uses __u32 etc.
> > 
> > But why the _kernel_ should include a userspace header is
> > much more questionable.
> 
> ok, i dropped this one for the time being.
> 
> Sam, Andrew, et al, i've got the commit lineup below, to fix the ~200 new 
> CONFIG_HEADERS_CHECK=y warnings we have in current -git, on x86 
> allyesconfig.
> 
> Note that i have restructured the tree and the commits so that this effort 
> can be tracked more easily: each commit has a "headers_check fix" subject 
> line prefix. So you can go back later and revisit these things - for 
> example whether a header really needs to be exported to user-space, via:
> 
>   git log --grep='headers_check fix:' --pretty=format:"%h: %s"
> 
> to get an overview and a historic track record. We can follow this 
> notation in the future too.
> 
> So if there are no objections, i'll send this to Linus tomorrow-ish and 
> we'll have the worst of the fallout behind us and can embark on a much 
> more fluid (and per maintainer) headers_check related workflow.

Thanks for taking care of this Ingo and please push towards Linus.
And thanks to all the contributors too - it was great to see this dealt
with soo quickly!

	Sam
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
