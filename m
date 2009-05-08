From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: bond + tc regression ?
Date: Sat, 9 May 2009 00:05:38 +0300
Message-ID: <200905090005.38712.denys@visp.net.lb>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <200905070046.27551.denys@visp.net.lb> <1241815571.7242.48.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:47087 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932164AbZEHVFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 17:05:46 -0400
In-Reply-To: <1241815571.7242.48.camel@hazard2.francoudi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 08 May 2009 23:46:11 Vladimir Ivashchenko wrote:
> > > Without IRQ balancing, one of the cores goes around 10% idle and HTB
> > > doesn't do its job properly. Actually, in my experience HTB stops
> > > working properly after idle goes below 35%.
> >
> > It seems they should. No idea, more experienced guys should know more.
> >
> > Can you show me please
> > cat /proc/net/psched
> > If it is highres working, try to add in HTB script, first line
> >
> > HZ=1000
> > to set environment variable. Because if clock resolution high, burst
> > calculation going crazy on high speeds.
> > Maybe it will help.
>
> Wow, instead of 98425b burst, its calculating 970203b.
Kind of strange burst, something wrong there. For 1000HZ and 1 Gbit it should 
be 126375b. You value is for 8Gbit/s.
What version of iproute2 you are using ( tc -V )?

>
> Exporting HZ=1000 doesn't help. However, even if I recompile the kernel
> to 1000 Hz and the burst is calculated correctly, for some reason HTB on
> 2.6.29 is still worse at rate control than 2.6.21.
>
> With 2.6.21, ceil of 775 mbits, burst 99425b -> actual rate 825 mbits.
> With 2.6.29, same ceil/burst -> actual rate 890 mbits.
It depends also if there is child classes, what is bursts set for them, and 
what is ceil/burst set for them.

>
> Moreover, after I stop the traffic *COMPLETELY* on 2.6.29, actual rate
> reported by htb goes ballistic and stays at 1100mbits. Then it drops
> back to expected value after a minute or so.
It is average bandwidth for some period, it is not realtime value. 

>
> > Also without irq balance, did you try to assign interface to cpu by
> > smp_affinity? (/proc/irq/NN/smp_affinity)
>
> Yes, I did, didn't make any difference.
What is a clock source?
cat /sys/devices/system/clocksource/clocksource0/current_clocksource
Timer resolution?
cat /proc/net/psched

>
> > And still i think best thing is oprofile. It can show "hot" places in
> > code, who is spending cpu cycles.
>
> For some reason I get a hard freeze when I start oprofile daemon, even
> without traffic. Never used oprofile before, so I'm not sure if I'm
> doing something wrong ... I'm starting it just with --vmlinux parameter
> and nothing else. I use vanilla 2.6.29 and oprofile from FC8.


