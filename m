From: dormando <dormando@rydia.net>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Wed, 6 Mar 2013 16:41:37 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1303061631290.6723@dflat>
References: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>   <51356AC1.4090302@gmail.com> <1362460046.15793.111.camel@edumazet-glaptop>  <alpine.DEB.2.02.1303042138330.7811@localhost6.localdomain6>
 <1362494795.15793.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:43226 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754803Ab3CGAlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 19:41:39 -0500
In-Reply-To: <1362494795.15793.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, 2013-03-04 at 21:44 -0800, dormando wrote:
>
> > No 3rd party modules. There's a tiny patch for controlling initcwnd from
> > userspace and another one for the extra_free_kbytes tunable that I brought
> > up in another thread. We've had the initcwnd patch in for a long time
> > without trouble. The extra_free_kbytes tunable isn't even being used yet,
> > so all that's doing is adding a 0 somewhere.
> >
> > Only two iptables rules loaded: global NOTRACK rules for PREROUTING/OUTPUT
> > in raw.
> >
> > Kernel's as close to pristine as I can make it. We had the 10g patch in
> > but I've dropped it.
> > --
>
> Hmm, I spent time on this bug report but found nothing.
>
> Please post as much information as you can on your setup.
>
> I see you use macvlan, bridge, so maybe there is a configuration issue
> (and a kernel bug of course)

Ok... bridge module is loaded but nothing seems to be using it. No
bond/tunnels/anything enabled. I couldn't quickly figure out what was
causing it to load.

We removed the need for macvlan, started machines with a fresh boot, and
they still crashed without it, after a few hours.

Unfortunately I just saw a machine crash in the same way on 3.6.6 and
3.6.9. I'm working on getting a completely pristine 3.6.6 and 3.6.9
tested. Our patches are minor but there were a few, so I'm backing it all
out just to be sure.

Is there anything in particular which is most interesting? I can post lots
and lots and lots of information. Sadly bridge/macvlan weren't part of the
problem. .config, sysctls are easiest I guess? When this "hang" happens
the machine is still up somewhat, but we lose access to it. Syslog is
still writing entries to disk occasionally, so it's possible we could set
something up to dump more information.

It takes a day or two to cycle this, so it might take a while to get
information and test crashes.

thanks,
-Dormando
