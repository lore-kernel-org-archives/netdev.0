From: Thomas Graf <tgraf@suug.ch>
Subject: Re: source routing - bug?
Date: Wed, 15 Jun 2005 03:24:16 +0200
Message-ID: <20050615012416.GF22463@postel.suug.ch>
References: <Pine.BSI.4.61.0506061455340.11929@malasada.lava.net> <20050615010548.GE22463@postel.suug.ch> <Pine.BSI.4.61.0506141513050.28194@malasada.lava.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Tim Newsham <newsham@lava.net>
Content-Disposition: inline
In-Reply-To: <Pine.BSI.4.61.0506141513050.28194@malasada.lava.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Tim Newsham <Pine.BSI.4.61.0506141513050.28194@malasada.lava.net> 2005-06-14 15:15
> >>   $ nc -g A -g B C 3333
> >>       I see packets forwarded over lo to A, and no further packets
> >>       are sent over lo or eth0.  Machines B and C receive no packets.
> >
> >A 127.0.0.1 source address is considered martian by the source
> >validation code as proposed by rfc1812. You should see warnings
> >in the console if you have martian logging enabled.
> 
> I see the same behavior when the source address is explicitely bound
> to an address belonging to a local NIC (-s option to netcat).

Since your local address is not a unicast you'll run into the same
martian rule as below.

> >A will do a route lookup of [src=A dst=A] which results in your
> >local route being returned. Again this violates rfc1812 because
> >that route will not be a unicast route but a local one. A martian
> >source warning should be logged if enabled.
> 
> Is there any way to enable routing for this case?  This is a
> desirable source route at times.  I would hate to have to boot
> FreeBSD every time I want to use this feature.

I can only think of one way which is to change fib_validate_source()
and have it accept RTN_LOCAL routes as well, i.e. change

	if (res.type != RTN_UNICAST)

into

	if (res.type != RTN_UNICAST && res.type != RTN_LOCAL)

I'm not sure if this breaks other code though.
