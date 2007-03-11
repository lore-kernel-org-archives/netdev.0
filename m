From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Sun, 11 Mar 2007 21:11:49 +0100
Message-ID: <20070311201148.GA25938@p15091797.pureserver.info>
References: <20070307020310.GA20466@bougret.hpl.hp.com> <1173364747.14001.7.camel@johannes.berg> <20070308184954.GA24485@bougret.hpl.hp.com> <1173382042.3248.63.camel@johannes.berg> <20070308193412.GG23040@devicescape.com> <1173382802.3248.68.camel@johannes.berg> <20070308221128.GA24884@bougret.hpl.hp.com> <1173393326.3831.21.camel@johannes.berg> <20070309213531.GA28070@bougret.hpl.hp.com> <1173634801.3382.8.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org, Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1173634801.3382.8.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I'm still not convinced that papering over the problem in userspace is a
> real solution.
> 
> johannes

Just my 2 cents. I support this. What are the options? I see only
two:

1. Use different magic numbers for 32 bit and 64 bit structures. A
   flag is an alternative, but will be more difficult to debug.
   Generation of the magic should be easy, use sizeof(unsigned
   long) as test. User space has to care than for the rest.

2. Make the data representation identical in 32 bit and 64 bit.

   This shouldn't be to difficult, if only u8, u16 and u32 types
   are used. Pointers should be given as offsets. If necessary
   align and/or packed attributes could be used.

If the kernel interface can be changed, I vote for option 2,
because user space has then to deal with a unique data layout.
If the wext kernel interface cannot be changed to maintain
backward compatibility, then I have to admit band-aids in user
space are needed. However cfg80211 must not suffer from the same issues.

-- 
Uli Kunitz
