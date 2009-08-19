From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH V2] lib/vsprintf.c: Add struct sockaddr *
 "%pN<foo>" output
Date: Wed, 19 Aug 2009 15:36:31 -0700
Message-ID: <1250721391.3407.103.camel@Joe-Laptop.home>
References: <1250230925.6641.92.camel@fnki-nb00130>
	 <20090814.001519.40499255.davem@davemloft.net>
	 <1250237739.16632.12.camel@fnki-nb00130>
	 <20090814.131218.139318801.davem@davemloft.net>
	 <1250349894.4620.5.camel@Joe-Laptop.home>
	 <1250395818.4625.15.camel@Joe-Laptop.home>
	 <2D3306C4-4DF4-4E3E-BBC2-2032058FA673@oracle.com>
	 <1250714657.3407.77.camel@Joe-Laptop.home>
	 <6EE37F10-4354-49FE-9FF1-BB38BDD10E6E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jens@mcbone.net, brian.haley@hp.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1803 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbZHSWgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 18:36:40 -0400
In-Reply-To: <6EE37F10-4354-49FE-9FF1-BB38BDD10E6E@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-19 at 18:20 -0400, Chuck Lever wrote:
> On Aug 19, 2009, at 4:44 PM, Joe Perches wrote:
> > I'm not too sure there's much value in ever more formatters for
> > relatively simple things or in printing something like port or
> > scope without the ip address.
> >
> > %hu ntohs(sa6->sin6_port)
> > or
> > %d or 0x%x ntohl(sa6->sin6_flowinfo)
> >
> > seem pretty straightforward to me.
> 
> It's the same issue for port numbers as it is for addresses: though  
> the port field is the same size in each, it's at different offsets in  
> AF_INET and AF_INET6 addresses, so extra logic is still needed to sort  
> that at each call site.
> 
> As an example, an rpcbind query cares about the port number result,  
> but usually not the address.  A human-readable message could show the  
> returned port number, but leave out the address.  Without a separate  
> formatter, you would still need extra logic around each debugging  
> message (for example) to choose how to print the port number.
> 
> You could probably argue, though, that this is a less common need than  
> printing addresses.

I suppose an address exclude could be added to %pN
if really needed.  Maybe "%pNx(specifiers)"

> > Here's another tentative patch that does both using square
> > brackets around IPv6 addresses with a port number and
> > allows selection of the port number style ":dddd" or ":hi.lo"
> 
> The "hi.lo" form is always separated from the address by a dot, not by  
> a colon, and square brackets are never used in that case.  The hi.lo  
> format is probably enough of a special case that a separate specifier  
> for that one is unnecessary.

Is the RPC code never used with a ipv6_addr_v4mapped address?
::192.168.0.1.1.1 would look pretty ugly

> Having a hexadecimal port number option  
> might be more useful.  The hexadecimal form is also used by the  
> kernel's RPC implementation, fwiw.

Easy enough. %pNhp or some such.

> > It also adds a "pI6n" form for IPv6 addresses with 7 colons
> > and no leading 0's.
> What would the 7 colons form be used for?

Shorter output requiring colon parsing, no :: parsing.
It's easier for humans to visually scan than the
leading 0 form.

