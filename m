From: Hans Nieser <hnsr@xs4all.nl>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Wed, 23 Feb 2011 13:21:44 +0100
Message-ID: <1298463704.31256.29.camel@krikkit>
References: <1298396007.23906.27.camel@krikkit>
	 <20110223095538.GA12662@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110223095538.GA12662@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-02-23 at 10:55 +0100, Francois Romieu wrote:
> Hans Nieser <hnsr@xs4all.nl> :
> [...]
> > With your patches applied to 2.6.38-rc6, I have gathered some of the
> > info you requested from Seblu as well, I hope it's helpful:
> > 
> > 1: see attachment
> 
> Ok.
> 
> The chipset requires no trivial last minute regression fix (yet).
> 
> > 2: I'm not sure how to check the size of the packets, but I'm just
> > fetching a (large) file over http/tcp, so I guess they are mostly of the
> > size of my MTU which is 1500 looking at ifconfig output
> 
> Fine.
> 
> Your testcases are always based on a real download, whence including some
> disk activity, as opposed to a pure network test, right ?

Yeah, I just had a little script that wgetted a file from a webserver in
my LAN and saved it to separate (non-root) fs, then removed it - in a
loop. When testing on the 2.6.35 and 2.6.35.9 kernels it did max out at
about 107MiB/s, sometimes falling down a little presumably when disk was
being touched.

> > For the other vmstat/ethtool/interrupts output, I started the following
> > commands remotely via ssh a second or two before starting the download,
> > and the machine locked up a few seconds later:
> 
> SysRq is enabled (/etc/sysctl.conf::kernel.sysrq = 1), the computer was
> switched back on a no-X console before the test. Then the keyboard leds
> ignore keypresses and the sysrq keys don't display anything in the
> console, right ?

Yep I had X shutdown and switched to VT1, after lock up the LEDs can't
be toggled anymore and sysrq key combo was nonresponsive (it works if I
do it before it locks up)

> You may enable PCIEASPM_DEBUG, force 'pcie_aspm=off' and switch from
> SLUB to SLAB but it's a bit cargo-cultish.

I'll give that a try this evening

> A bisection could help. Bisecting 2.6.35 .. 2.6.35.9 may be enough if
> 2.6.35.9 works well.

Hmm did you mean bisecting 2.6.36 - 2.6.35.9 ? Since with 2.6.36 and
above I can get the machine to hang within seconds and performance is
really bad (10-20MiB/s with wget), while with 2.6.35.9 and 2.6.35
performance was really good (reaching 107MiB/s most of the time) and
lock up took 5-10 minutes instead of seconds (I guess I didn't mention
this in my last e-mail but I managed to get both 2.6.35 and 2.6.35.9 to
lock up eventually) - but I guess something changed between .35 and .36
that made the issue easier to trigger.

I can also try even older kernels to see if there is one that doesn't
lock up at all
