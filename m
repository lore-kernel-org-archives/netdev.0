From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: (usagi-core 15040) [PATCH] IPv6: Protect proxied addresses
 against DAD
Date: Wed, 20 Aug 2003 22:39:33 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820.223933.69651454.yoshfuji@linux-ipv6.org>
References: <20030820.204304.07033882.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0308201449550.756-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0308201449550.756-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0308201449550.756-200000@rhea.tcs.hut.fi> (at Wed, 20 Aug 2003 15:58:08 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> > >  		if (in6_dev && in6_dev->cnf.forwarding &&
> > > -		    (addr_type & IPV6_ADDR_UNICAST) &&
> > > +		    (addr_type & IPV6_ADDR_UNICAST ||
> > > +		     addr_type == IPV6_ADDR_ANY) &&
> > >  		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0)) {
> > >  			int inc = ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
> > >
> >
> > I believe we don't need this chunk.
> 
> No, it is needed. Normal neighbor solicitations are sent using a unicast
> source address, but DAD probes are sent using the unspecified address as
> source.

Oops, sorry, I read it as it were "ANYCAST."
I agree.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
