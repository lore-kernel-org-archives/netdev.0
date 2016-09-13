From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: icmpv6: issue with routing table entries from link local
 addresses
Date: Mon, 12 Sep 2016 23:05:18 -0400
Message-ID: <20160913030518.GA30030@oracle.com>
References: <20160912142732.GI26782@targo.k4n.de>
 <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
 <CACP96tTFX7nyGz6uARYxemvE7-WDxvX7Wj+Jf95PC0Advy7ynw@mail.gmail.com>
 <e2eddc8d-ccd6-682b-265f-55242eef1762@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sowmini Varadhan <sowmini05@gmail.com>,
        Andreas =?iso-8859-1?Q?H=FCbner?= <andreas@k4n.de>,
        netdev <netdev@vger.kernel.org>,
        "d. caratti" <davide.caratti@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24608 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbcIMDFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 23:05:39 -0400
Content-Disposition: inline
In-Reply-To: <e2eddc8d-ccd6-682b-265f-55242eef1762@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/13/16 04:42), Hannes Frederic Sowa wrote:
> > But a couple of unexpected things I noticed in linux: the link-local
> > prefix should have a prefixlen of /10 according to
> > http://www.iana.org/assignments/ipv6-address-space/ipv6-address-space.xhtml
> > but "ip -6 route show"  lists this as a /64..
> 
> The link local subnet is still specified to be a /64 as the other parts
> of the address must be 0. Legally we probably could blackhole them.
> https://tools.ietf.org/html/rfc4291#section-2.5.6

A bit of a gray area. 4291 does not specify this as MBZ, and IANA
registration is a /10. Both Solaris and BSD use /10. And while fec0
is deprecated, I suppose some similar thing could come up in the
future. ymmv.

> We don't have urpf checks for ipv6, those are implemented in netfilter
> only. This could very well be a firewall issue or something like that.

yes, I know that (no rp_filter check for ipv6), and thats why I said it
may be some similar variant.  What tripped me up is that onlink prefixes 
(which are multipath routes in that they have the same dst, mask, metric)
are not treated as part of the typical IP_ROUTE_MULTIPATH in many places 
in the code because the fib_nhs data-structures do not get set up.
(thus, e.g., one ipoib config I was looking at recently, which 
had multiple ports connected to the same IB switch, and had the same
onlink prefix on these ports,  would not load-spread across all ports
until I explicitly did the 'ip route change' to tell the kernel to
ecmp that prefix).

Lets see what Andreas reports..

--Sowmini
