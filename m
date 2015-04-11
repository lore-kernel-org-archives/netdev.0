From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] net/wireless: CFG80211_WEXT_EXPORT requires wireless extensions
Date: Sat, 11 Apr 2015 22:41:37 +0200
Message-ID: <4904912.VjuX4Pm71s@wuerfel>
References: <2303996.H1mYPouv05@wuerfel> <1428733011.2139.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428733011.2139.1.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 11 April 2015 08:16:51 Johannes Berg wrote:
> On Sat, 2015-04-11 at 00:29 +0200, Arnd Bergmann wrote:
> > The CFG80211_WEXT_EXPORT symbol is selected by two drivers that
> > make direct use of compat handlers for the wireless ioctls.
> > However, this has no effect when the wireless extensions themselves
> > are disabled, and results in a link error:
> > 
> > ERROR: "cfg80211_wext_giwrts" [drivers/net/wireless/orinoco/orinoco.ko] undefined!
> > ERROR: "cfg80211_wext_siwfrag" [drivers/net/wireless/orinoco/orinoco.ko] undefined!
> > ERROR: "cfg80211_wext_giwname" [drivers/net/wireless/ipw2x00/ipw2200.ko] undefined!
> > 
> > This changes the Kconfig logic so that CFG80211_WEXT can not
> > be disabled when CFG80211_WEXT_EXPORT is set.
> 
> > +++ b/net/wireless/Kconfig
> > @@ -178,7 +178,6 @@ config CFG80211_WEXT
> >       bool "cfg80211 wireless extensions compatibility"
> 
> (I added "if !CFG80211_WEXT_EXPORT" to this line)

Right, that works just as well, thanks!

> >       depends on CFG80211
> >       select WEXT_CORE
> > -     default y if CFG80211_WEXT_EXPORT
> >       help
> >         Enable this option if you need old userspace for wireless
> >         extensions with cfg80211-based drivers.
> > @@ -186,6 +185,7 @@ config CFG80211_WEXT
> >  config CFG80211_WEXT_EXPORT
> >       bool
> >       depends on CFG80211
> > +     select CFG80211_WEXT
> 
> This doesn't work afaict because select won't go through if this is
> selected. I've already sent a fix for this in my latest pull request
> that has the above.

As Paul commented, it does work, and I have of course checked that my
patch fixes the problem without introducing other build failures.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
