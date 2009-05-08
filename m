From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: bond + tc regression ?
Date: Sat, 9 May 2009 01:07:27 +0300
Message-ID: <20090508220727.GA26865@francoudi.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <200905070046.27551.denys@visp.net.lb> <1241815571.7242.48.camel@hazard2.francoudi.com> <200905090005.38712.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:3575 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092AbZEHWH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 18:07:29 -0400
Content-Disposition: inline
In-Reply-To: <200905090005.38712.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Wow, instead of 98425b burst, its calculating 970203b.
> Kind of strange burst, something wrong there. For 1000HZ and 1 Gbit it should 
> be 126375b. You value is for 8Gbit/s.
> What version of iproute2 you are using ( tc -V )?

That was iproute2-ss080725, I think it is confused by tickless mode.
With iproute2-ss090324 I'm getting an opposite: 1589b :)

> >
> > With 2.6.21, ceil of 775 mbits, burst 99425b -> actual rate 825 mbits.
> > With 2.6.29, same ceil/burst -> actual rate 890 mbits.
> It depends also if there is child classes, what is bursts set for them, and 
> what is ceil/burst set for them.

All child classes have smaller bursts than the parent. However, there are two 
sub-classes which have ceil at 70% of parent, e.g. ~500mbit each. I
don't know HTB internals, perhaps these two classes make the parent class 
overstretch itself.

By the way, I experience the same "overstretching" with hfsc. In any case, 
I prefer HTB because it reports statistics of parent classes, unlike hfsc.

> > Moreover, after I stop the traffic *COMPLETELY* on 2.6.29, actual rate
> > reported by htb goes ballistic and stays at 1100mbits. Then it drops
> > back to expected value after a minute or so.
> It is average bandwidth for some period, it is not realtime value. 

But why it would it jump from 850mbits to 1200mbits *AFTER* I remove all
the traffic ?

> > Yes, I did, didn't make any difference.
> What is a clock source?
> cat /sys/devices/system/clocksource/clocksource0/current_clocksource

tsc

> Timer resolution?
> cat /proc/net/psched

With tickless kernel:

000003e8 00000400 000f4240 3b9aca00

-- 
Best Regards
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel, Cyprus - www.prime-tel.com
