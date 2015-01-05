From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Mon, 05 Jan 2015 11:05:01 +0100
Message-ID: <1420452301.9459.3.camel@sipsolutions.net>
References: <1420297188.2397.3.camel@tiscali.nl>
	 <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
	 <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>
	 <1420324124.9624.60.camel@x220> (sfid-20150103_232852_400842_25360CE9)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420324124.9624.60.camel@x220> (sfid-20150103_232852_400842_25360CE9)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-01-03 at 23:28 +0100, Paul Bolle wrote:
> On Sat, 2015-01-03 at 10:07 -0800, Linus Torvalds wrote:
> > On Sat, Jan 3, 2015 at 10:02 AM, Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> wrote:
> > >
> > > why would you revert this? It is obviously the correct change to actually select CFG80211_WEXT.
> > 
> > I don't know about obvious, but yeah, I think the select in this case
> > is actually the better idea anyway.
> 
> Obviously it wasn't obvious to me!
> 
> My reasoning was that the "ipw2200: select CFG80211_WEXT" commit was
> _solely_ a workaround for the breakage introduced by that other patch.
> And since that one is now reverted the workaround wasn't needed anymore.

Well, you thought of it only as a workaround - but it makes sense. You
shouldn't have to 

> Besied, I thought we try to avoid select-ing symbols that can also be
> set manually. As that makes it more likely to trigger circular
> dependency problems in the kconfig tools, doesn't it?

I don't think that has much to do with whether or not they can be set
manually - it's more a question of what the dependencies of the selected
symbol are. In this case it's a bool leaf symbol with the only
dependency being something ipw already needs, so it's pretty much
guaranteed to be safe.

> Side note: am I correct in thinking that there's some successor to
> CFG80211_WEXT and that the ipw2200 driver could, at least in theory, be
> ported to that successor? (ipw2200 hardware appears to be a bit old, so
> probably no one would care enough to actually do that.)
> net/wireless/kconfig doesn't mention anything like that, so probably I'm
> just confused.

Well, see the big thread over there with the revert that I'm tempted to
not even read ...

The real successor, for various reasons (like simply always being able
to connect to a single AP, no matter how many others can be found by
scanning!), is nl80211.

Many drivers have been converted to the new framework by using mac80211,
but some drivers cannot use mac80211 because they do more in the
device/firmware. Among those are many of the old 11b/11g ones that still
exist in the tree, but also a few new ones (like mwifiex) that were
already written to cfg80211 APIs.

It should definitely be possible to convert all the drivers (*) to pure
cfg80211 instead of having direct userspace wext to driver calls - but
nobody has gone and done it.

johannes

(*) caveat - at least the playstation3 driver will require some new
nl80211 API

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
