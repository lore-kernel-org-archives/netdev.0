From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Mon, 7 Mar 2016 08:54:48 -0800
Message-ID: <CAA93jw4JG_uEZaxk1JDKndq9K0+QPwKaAmK6=gZ8e-7qNmc=Cw@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<E1abfnE-0000VS-00@www.xplot.org>
	<CA+BoTQk6J7kgdie9aX24MB+8PxN3oFUh0eVdmVrdyptW5RxQXg@mail.gmail.com>
	<CAPp0ZBYP9UzUTtPz=vivUQkE2FiGSsJjDaecQtPuK8y_d3ccqA@mail.gmail.com>
	<56DD99AA.8050403@openwrt.org>
	<CAHqTa-2-uZ0PUdwp33E588EU2a7T6KnTYs8RWfNDEzgOLseG9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
	Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andrew Mcgregor <andrewmcgr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke-LJ9M9ZcSy1A@public.gmane.org>
To: Avery Pennarun <apenwarr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHqTa-2-uZ0PUdwp33E588EU2a7T6KnTYs8RWfNDEzgOLseG9g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If I can just get a coherent patch set that I can build, I will gladly
join you on the testing ath9k in particular... can probably do ath10k,
too - and do a bit of code review... this week. it's very exciting
watching all this activity...

but I confess that I've totally lost track of what set of trees and
patchwork I should try to pull from. wireless-drivers-next? ath10k?
wireless-next? net-next? toke and I have a ton of x86 platforms
available to test on....

Avery - which patches did you use??? on top of what?

In terms of "smoothing" codel...

I emphatically do not think codel in it's current form is "ready" for
wireless, at the very least the target should not be much lower than
20ms in your 2 station tests.  There is another bit in codel where the
algo "turns off" with only a single MTU's worth of packets
outstanding, which could get bumped to the ideal size of the
aggregate. "ideal" kind of being a variable based on a ton of other
factors...

the underlying code needs to be striving successfully for per-station
airtime fairness for this to work at all, and the driver/card
interface nearly as tight as BQL is for the fq portion to behave
sanely. I'd configure codel at a higher target and try to observe what
is going on at the fq level til that got saner.

There are so many other variables and things left unaccounted for, as yet.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
