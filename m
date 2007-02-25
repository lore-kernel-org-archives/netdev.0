From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Sun, 25 Feb 2007 20:06:56 +0300
Message-ID: <20070225170656.GA14698@2ka.mipt.ru>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl> <20070220164124.GA24930@2ka.mipt.ru> <20070225104154.GA2045@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: bert hubert <bert.hubert@netherlabs.nl>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964989AbXBYRHd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070225104154.GA2045@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 25, 2007 at 11:41:54AM +0100, Pavel Machek (pavel@ucw.cz) wrote:
> > > I've done so, with some interesting results. Source on
> > > http://ds9a.nl/tmp/recvtimings.c - be careful to adjust the '3000' divider
> > > to your CPU frequency if you care about absolute numbers!
> > > 
> > > These are two groups, each consisting of 10 consecutive nonblocking UDP
> > > recvfroms, with 10 packets preloaded. Reported is the number of microseconds
> > > per recvfrom call which yielded a packet:
> > > 
> > > $ ./recvtimings
> > > 4.142333
> > 
> > It can be recvfrom only problem - syscall overhead on my p4 (core duo,
> > debian testing) is bout 300 usec - to test I ran 
> 
> core duo is _not_ p4 class cpu; rsulets there will be very different.

Results nevertheless are the same.
Each syscall takes some time first (noticebly more than subsequent
calls), and that was a main problem for Bert.
Given the high load, recvfrom() can even take tens of microseconds
(although I can not provide a profile output yet, but I showed a data).

So, syscall overhead itself is very small no matter which type of the
CPU is used - athlon is about 300 nsec, via epia about 1.4 usec), 
but the whole function can take quite a lot of time.

> 									Pavel
> 
> -- 
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

-- 
	Evgeniy Polyakov
