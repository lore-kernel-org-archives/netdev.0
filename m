From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Tue, 30 Mar 2010 07:20:44 +0200
Message-ID: <20100330052044.GJ20695@one.firstfloor.org>
References: <1269561751.2891.8.camel@ilion> <877how25kx.fsf@basil.nowhere.org> <4BB0DCF6.9020401@hp.com> <20100329201431.GH20695@one.firstfloor.org> <20100329205035.GA32656@laped.iglesias.mooo.com> <4BB11510.9000302@hp.com> <1269898152.1958.86.camel@edumazet-laptop> <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Edgar E. Iglesias" <edgar.iglesias@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51474 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab0C3FUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 01:20:49 -0400
Content-Disposition: inline
In-Reply-To: <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 04:38:49PM -0700, Templin, Fred L wrote:
> > 1) 4096 bytes UDP messages... well...
> > 2) Using regular TCP for DNS servers... well...
> > 
> > I believe some guys were pushing TCPCT (Cookie Transactions) for this
> > case ( http://tools.ietf.org/html/draft-simpson-tcpct-00.html )
> > 
> > (That is, using an enhanced TCP for long DNS queries... but not only for
> > DNS...)
> 
> IPv4 gets by this by setting DF=0 in the IP header, and
> lets the network fragment the packet if necessary. IPv6 can
> similarly get by this by having the sending host fragment
> the large UDP packet into IPv6 fragments no longer than
> 1280 bytes each.

That's true -- in theory the UDP app unwilling/unable to do proper ptmudisc 
could set the path mtu to 1280 + header and still keep path mtu discovery off 
and then just fragment. 

Drawback would be of course suboptimal network use with too small MTUs
in the common case.

Right now there is no right socket option to set the path mtu. We
have a IP_MTU option, but it only works for getting the MTU.
That's because the PMTU is in the routing cache entry and shared
by multiple sockets. Presumably one could add a special case
with an MTU in the socket overriding the one in the destination entry.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
