From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net-next-2.6] etherdevice.h: Add is_unicast_ether_addr
	function
Date: Thu, 13 Jan 2011 09:35:19 +0100
Message-ID: <20110113083519.GW29757@distanz.ch>
References: <20110112.234250.10542369.davem@davemloft.net> <1294906496-14950-1-git-send-email-tklauser@distanz.ch> <1294907081.4114.35.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cmetcalf@tilera.com,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:40864 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756090Ab1AMIfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 03:35:20 -0500
Content-Disposition: inline
In-Reply-To: <1294907081.4114.35.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-01-13 at 09:24:41 +0100, Joe Perches <joe@perches.com> wrote:
> On Thu, 2011-01-13 at 09:14 +0100, Tobias Klauser wrote:
> > >From a check for !is_multicast_ether_addr it is not always obvious that
> > we're checking for a unicast address. So add this helper function to
> > make those code paths easier to read.
> >  include/linux/etherdevice.h |   11 +++++++++++
> []
> >  /**
> > + * is_unicast_ether_addr - Determine if the Ethernet address is unicast
> > + * @addr: Pointer to a six-byte array containing the Ethernet address
> > + *
> > + * Return true if the address is a unicast address.
> > + */
> > +static inline int is_unicast_ether_addr(const u8 *addr)
> > +{
> > +	return !is_multicast_ether_addr(addr);
> > +}
> 
> Can't you simply use is_valid_ether_addr?

I added is_unicast_ether_addr to make the intention of checking for a
unicast address clearer (see [1] for context).

[1] http://article.gmane.org/gmane.linux.network/183615

> I can't think of much reason that a new function for
> !multicast without the !is_zero is needed.

Maybe I should just add something like the following?

#define is_unicast_ether_addr(addr) is_valid_ether_addr(addr)
