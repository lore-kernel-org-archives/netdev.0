From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gre: minor cleanups in netlink interface
Date: Sat, 11 Oct 2008 23:03:40 +0800
Message-ID: <20081011150340.GA7520@gondor.apana.org.au>
References: <48EF7D24.6040400@trash.net> <20081011103935.GA6168@gondor.apana.org.au> <48F0BB77.6080401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44484 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752222AbYJKPDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 11:03:46 -0400
Content-Disposition: inline
In-Reply-To: <48F0BB77.6080401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 11, 2008 at 04:43:03PM +0200, Patrick McHardy wrote:
>
> No, its equivalant to using memcpy.

Great.

> We don't have much precedent for rtnl_link besides VLAN (which
> does support incremental changes), but actually all other route
> netlink interfaces do support incremental changes by sending only
> a subset of the attributes. A reason for supporting this in the
> interface is that incremental userspace changes will always be
> racy because you need two seperate operations.

It is true that it is going to be racy when done in user-space,
however that's easily solved with locking.  Even if we did the
incremental change in the kernel it only helps certain kinds of
usage scenarios.  For instance, if the race is between two updates
to the local address you're still going to need synchronisation
in user-space.

Having said that, I'm certainly not against changing the interface
since you do have precedence with the other two :)

Do be warned that doing this for GRE is going to be less trivial
than the existing rtnl link interfaces.  For example, we'll need
to break down the iflags/oflags into individual bits as otherwise
you'll be back in the same situation.  It's a good thing that
there aren't too many bits in use :)

Also, for ikey/okey we'll need to introduce another attribute to
indicate their presence as well as their value.

Hmm, it seems that there is a bug in how we treat a zero key.
You can't have a tunnel with a zero key and one with no key at
the same time.

In fact my latest iproute patch has a similar problem.  You
can't unset the ikey/okey except by deleting the tunnel.  On
the other hand the old ip tunnel interface has the same bug :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
