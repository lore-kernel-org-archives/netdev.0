From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1 take 2] Unified socket storage. (with small bench).
Date: Wed, 9 May 2007 13:34:43 +0400
Message-ID: <20070509093443.GA10028@2ka.mipt.ru>
References: <20070508174331.GA13591@2ka.mipt.ru> <20070508.234828.95506666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36771 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbXEIJgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 05:36:24 -0400
Content-Disposition: inline
In-Reply-To: <20070508.234828.95506666.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 11:48:28PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Tue, 8 May 2007 21:43:32 +0400
> 
> > This is second patch which implements unified cache of sockets for
> > network instead of old hash tables. It stores all types of sockets
> > (although I only implemented af_inet, unix, netlink and raw ones for now)
> > in single object structure called multidimensional trie (which is
> > similar to judy array in some way).
> 
> Thanks for doing this work it is very interesting. :)

:) it is interesting indeed.

> > So, this is dynamic structure which can host any kind of network sockets
> > (actually any structure pointer which can be addressed with 160 bits).
> > Structure can be extended to support ipv6 (needs to increase key
> > length) with essentially any number of elements in it.
> > 
> > Code is in development stage, but I would like to rise a discussion
> > about needs to continue this development before next steps.
> 
> One thing that will need to be adjust for current tree is the UDP
> hashing mechanism.  But as far as I can tell your code should be able
> to handle the new scheme (we now hash UDP by saddr+port when
> possible, and this reminds me that IPV6 is broken and needs some
> repairs).

Yes, udp with multicast can be a problem, but it can be solved exactly
the same way I implemented netlink broadcast (simple solution) -
multicast sockets are placed into own list/hash table/trie with special
bit in key/whatever and accessed when needed.

> What exactly does the 'stages' arg mean?  Is this a method to handle
> partially bound sockets?

It is a fallback to select a listening socket, which has remote
addr/port as zero, so when socket it selected from tree, lookup wants to
first get established socket with given remote identity and if this
fails, it tries to select a wildcard one.

-- 
	Evgeniy Polyakov
