From: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Sat, 03 Jan 2015 23:28:44 +0100
Message-ID: <1420324124.9624.60.camel@x220>
References: <1420297188.2397.3.camel@tiscali.nl>
	 <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
	 <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-01-03 at 10:07 -0800, Linus Torvalds wrote:
> On Sat, Jan 3, 2015 at 10:02 AM, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> wrote:
> >
> > why would you revert this? It is obviously the correct change to actually select CFG80211_WEXT.
> 
> I don't know about obvious, but yeah, I think the select in this case
> is actually the better idea anyway.

Obviously it wasn't obvious to me!

My reasoning was that the "ipw2200: select CFG80211_WEXT" commit was
_solely_ a workaround for the breakage introduced by that other patch.
And since that one is now reverted the workaround wasn't needed anymore.

Besied, I thought we try to avoid select-ing symbols that can also be
set manually. As that makes it more likely to trigger circular
dependency problems in the kconfig tools, doesn't it?

> We could make the CFG80211_WEXT help message be very negative so that
> people aren't encouraged to select it even if they can, but then if
> they need the ipw driver it gets selected because of that. Because the
> ipw driver is probably the more important of the two if you just
> happen to have old hardware but are upgrading yout software (and
> anybody who recompiles their own kernel is obviously doing the
> latter).

Side note: am I correct in thinking that there's some successor to
CFG80211_WEXT and that the ipw2200 driver could, at least in theory, be
ported to that successor? (ipw2200 hardware appears to be a bit old, so
probably no one would care enough to actually do that.)
net/wireless/kconfig doesn't mention anything like that, so probably I'm
just confused.


Paul Bolle

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
