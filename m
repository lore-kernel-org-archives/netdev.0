From: Patrick McHardy <kaber@trash.net>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 17:15:40 +0200
Message-ID: <48F0C31C.8080501@trash.net>
References: <48EF7D24.6040400@trash.net> <20081011103935.GA6168@gondor.apana.org.au> <48F0BB77.6080401@trash.net> <20081011150340.GA7520@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52218 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbYJKPPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 11:15:44 -0400
In-Reply-To: <20081011150340.GA7520@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Oct 11, 2008 at 04:43:03PM +0200, Patrick McHardy wrote:
>> We don't have much precedent for rtnl_link besides VLAN (which
>> does support incremental changes), but actually all other route
>> netlink interfaces do support incremental changes by sending only
>> a subset of the attributes. A reason for supporting this in the
>> interface is that incremental userspace changes will always be
>> racy because you need two seperate operations.
> 
> It is true that it is going to be racy when done in user-space,
> however that's easily solved with locking.  Even if we did the
> incremental change in the kernel it only helps certain kinds of
> usage scenarios.  For instance, if the race is between two updates
> to the local address you're still going to need synchronisation
> in user-space.

Thats true.

> Having said that, I'm certainly not against changing the interface
> since you do have precedence with the other two :)
> 
> Do be warned that doing this for GRE is going to be less trivial
> than the existing rtnl link interfaces.  For example, we'll need
> to break down the iflags/oflags into individual bits as otherwise
> you'll be back in the same situation.  It's a good thing that
> there aren't too many bits in use :)

We usually use two values (value + mask) for flags.

> Also, for ikey/okey we'll need to introduce another attribute to
> indicate their presence as well as their value.

The flags already indicate whether keys should be used, don't
they? So if you want to unset them, you can simply unset the
GRE_KEY flag.

I'll give it a shot and will post a patch, probably tommorrow.

> Hmm, it seems that there is a bug in how we treat a zero key.
> You can't have a tunnel with a zero key and one with no key at
> the same time.
> 
> In fact my latest iproute patch has a similar problem.  You
> can't unset the ikey/okey except by deleting the tunnel.  On
> the other hand the old ip tunnel interface has the same bug :)

I can't find it :)
