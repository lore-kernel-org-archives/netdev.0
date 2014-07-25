From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net] ip: make IP identifiers less predictable
Date: Fri, 25 Jul 2014 21:03:33 +0200
Message-ID: <20140725190333.GA31935@1wt.eu>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com> <CA+55aFyCDNq3E+bZ3aPfS33w8mA_86J+cNWR5V6fdogNihSh2Q@mail.gmail.com> <53D27E0E.40102@cs.unm.edu> <1406311751.3363.95.camel@edumazet-glaptop2.roam.corp.google.com> <CA+55aFwZrF88Fj7arP2P3rRshBTaxbjyJkKuOAu2Y4tVQ3kWWA@mail.gmail.com> <1406313497.3363.98.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jeffrey Knockel <jeffk@cs.unm.edu>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	"security@kernel.org" <security@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:46424 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978AbaGYTLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 15:11:20 -0400
Content-Disposition: inline
In-Reply-To: <1406313497.3363.98.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2014 at 08:38:17PM +0200, Eric Dumazet wrote:
> On Fri, 2014-07-25 at 11:35 -0700, Linus Torvalds wrote:
> > On Fri, Jul 25, 2014 at 11:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > >
> > > We might change the hash to use both daddr & saddr to increase
> > > protection.
> > 
> > .. and maybe protocol too, so that you can't easily use icmp echo
> > packets to do it for udp packets etc. The underlying jhash is
> > jhash_3words(), so that would actually be fairly natural for at least
> > ipv4 (the ipv6 case I didn't look at).
> 
> Right, in fact saddr is probably not worth it.

Yes it is, at least to isolate public and private networks.

> Its not like servers have dozen of IPv4 addresses anyway...

Actually some have many more, even hundreds sometimes (until people
realize they can bind networks to the loopback or do transparent
proxy, where the principle is still true). It's especially true with
front equipments such as reverse proxies and load balancers. SSL
deployed all over the web has made that much worse despite the
introduction of SNI which is not supported by all clients, because
while hosting providers used to assign just a few IPs on which they
bound their servers using virtual hosting, with SSL they tend to
offer one IP address per customer.

Regards,
Willy
