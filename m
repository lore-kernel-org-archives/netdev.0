From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: bond + tc regression ?
Date: Thu, 7 May 2009 00:46:27 +0300
Message-ID: <200905070046.27551.denys@visp.net.lb>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <200905062230.04594.denys@visp.net.lb> <20090506204759.GA16681@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:42765 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756446AbZEFVqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 17:46:33 -0400
In-Reply-To: <20090506204759.GA16681@francoudi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 May 2009 23:47:59 Vladimir Ivashchenko wrote:
> On Wed, May 06, 2009 at 10:30:04PM +0300, Denys Fedoryschenko wrote:
> > > What's interesting, the same 850mbps load, identical machine, but with
> > > only two NICs and no bond, HTB+esfq, kernel 2.6.21.2 => 60% CPU idle.
> > > 2.5x overhead.
> >
> > Probably oprofile can sched some light on this.
> > On my own experience IRQ balancing hurt performance a lot, because of
> > cache misses.
>
> This is a dual-core machine, isn't cache shared between the cores?
>
> Without IRQ balancing, one of the cores goes around 10% idle and HTB
> doesn't do its job properly. Actually, in my experience HTB stops working
> properly after idle goes below 35%.
It seems they should. No idea, more experienced guys should know more.

Can you show me please
cat /proc/net/psched
If it is highres working, try to add in HTB script, first line

HZ=1000
to set environment variable. Because if clock resolution high, burst 
calculation going crazy on high speeds.
Maybe it will help.

Also without irq balance, did you try to assign interface to cpu by 
smp_affinity? (/proc/irq/NN/smp_affinity)

And still i think best thing is oprofile. It can show "hot" places in code, 
who is spending cpu cycles.

>
> I'll try gathering some stats using oprofile.


