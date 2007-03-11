From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Sun, 11 Mar 2007 21:30:05 +0100
Message-ID: <200703112130.05717.mb@bu3sch.de>
References: <20070307020310.GA20466@bougret.hpl.hp.com> <1173634801.3382.8.camel@johannes.berg> <20070311201148.GA25938@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org,
	Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070311201148.GA25938-WhJF3imHnk+bHbQv0o6mQ2hcgWyyV7dXYZdqe9AaVak@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 11 March 2007 21:11, Ulrich Kunitz wrote:
> > I'm still not convinced that papering over the problem in userspace is a
> > real solution.
> > 
> > johannes
> 
> Just my 2 cents. I support this. What are the options? I see only
> two:
> 
> 1. Use different magic numbers for 32 bit and 64 bit structures. A
>    flag is an alternative, but will be more difficult to debug.
>    Generation of the magic should be easy, use sizeof(unsigned
>    long) as test. User space has to care than for the rest.
> 
> 2. Make the data representation identical in 32 bit and 64 bit.
> 
>    This shouldn't be to difficult, if only u8, u16 and u32 types
>    are used.

>    Pointers should be given as offsets.

Offsets to what?

>    If necessary  
>    align and/or packed attributes could be used.
> 
> If the kernel interface can be changed, I vote for option 2,
> because user space has then to deal with a unique data layout.
> If the wext kernel interface cannot be changed to maintain
> backward compatibility, then I have to admit band-aids in user
> space are needed. However cfg80211 must not suffer from the same issues.

All your suggestions break the userspace ABI on all machines,
which is a thing we _really_ want to avoid.

The right fix is to have a compatibility wrapper in the kernel,
but it turns out to be hard to implement. I don't think we want
to change the structures layout and break ABI.

-- 
Greetings Michael.
