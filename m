From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH FINAL] Merge the Sonics Silicon Backplane subsystem
Date: Wed, 1 Aug 2007 09:55:23 -0700
Message-ID: <20070801095523.458e00c1.akpm@linux-foundation.org>
References: <200707291324.58691.mb@bu3sch.de>
	<20070731202648.e1a8c45f.akpm@linux-foundation.org>
	<200708011133.37214.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200708011133.37214.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Aug 2007 11:33:36 +0200 Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:

> > 
> > yup, it's `select':
> > 
> > Selected by: B44 && NETDEVICES && NET_ETHERNET || BCM43XX_MAC80211 && NETDEVICES && !S390 && MAC80211 && WLAN_80211 && EXPERIMENTAL
> > 
> > 
> > Look.  Kconfig's `select' Just.  Does.  Not.  Work.  If you find yourself
> > contemplating using it, please, don sackcloth, take a cold shower and
> > several analgesics, then have another go, OK?
> > 
> > ho hum.
> 
> Ah, yeah. Crap select not caring about dependencies...
> The problem is that people will kill me, if they don't find
> bcm43xx in the kconfig anymore, as they have to enable ssb
> before that. Ya know the flame with Uwe Bugla going crazy
> about that? :D
> Same goes for b44. It was always there in kconfig without
> additional deps, but now (when we merge the b44 port) we would
> need ssb selected before we see b44.

We just don't have a good solution to this.

`select' is bust and it's unobvious how it can _not_ be bust.  If you're
selecting something whose dependencies aren't met, what can we do?  Maybe
select the thing it depends on as well?  What if it depends on (A||B)? 
Which one do we force on?  Screwed.

And hiding options from the users until theyve gone elsewher and selected
something else is most user-hostile.

At least we have menuconfig's "/" command, so if you know the option's name
you can work out why it isn't appearing.

I think what we should do is to continue to offer the unselectable option
in manuconfig and friends, only "greyed out" in some fashion.  So the user
can still navigate to it and select the "what do you depend on" button.

> Maybe default SSB to M?

People would complain about that too.  I don't know what to do, sorry. 
Muddle through :(
