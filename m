From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: changing dev->needed_headroom/needed_tailroom?
Date: Tue, 20 Aug 2013 09:20:13 -0700
Message-ID: <20130820092013.6ca909e2@nehalam.linuxnetplumber.net>
References: <1374850210.8248.59.camel@jlt4.sipsolutions.net>
	<1375433758.24371.20.camel@deadeye.wl.decadent.org.uk>
	<1375449082.3927.5.camel@edumazet-glaptop>
	<1375711240.8120.11.camel@jlt4.sipsolutions.net>
	<CAGVrzcaGV6AqLTAxpM6zMv7_C-LNxp-WNg+J47d7a9S+Ca1bDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGVrzcaGV6AqLTAxpM6zMv7_C-LNxp-WNg+J47d7a9S+Ca1bDw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Aug 2013 11:00:18 +0100
Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> 2013/8/5 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>:
> > On Fri, 2013-08-02 at 06:11 -0700, Eric Dumazet wrote:
> >> On Fri, 2013-08-02 at 10:55 +0200, Ben Hutchings wrote:
> >>
> >> > I don't think this is safe when the interface is running (even if
> >> > carrier is off).  Some functions may read dev->needed_headroom twice and
> >> > rely on getting the same value each time.
> >>
> >> It should be no problem. Remaining unsafe places should be fixed.
> >
> > Most interesting would be stack devs, which I hadn't even considered. In
> > any case, since I can't completely _rely_ on it, it's an optimisation,
> > the only bugs would be around the double-access and then running
> > over/under the SKB or so?
> 
> As far as I could test this with an Ethernet driver which adjusted its
> needed_headroom by 64 bytes whenever some hardware feature was
> enabled/disabled, this expectedly broke bridge and vlans at least.
> Bridge code does not use the slave ports needed_headroom values, and
> VLAN devices get the parent device needed_headroom only when creating
> the vlan device. The good thing is since the needed_headroom space you
> need is most likely fixed for a given configuration type, you should
> see a pretty "stable" corruption of your SKB head.

All code must check for needed headroom first, and copy packet
if space is not available. Since excess headroom is always safe,
most devices just always use the same worst case headroom.

Even with your changes this will still be necessary since packets will
be still in flight while features change.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
