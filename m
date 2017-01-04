From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH repost net-next] dsa: mv88e6xxx: Optimise atu_get
Date: Wed, 4 Jan 2017 22:19:57 +0100
Message-ID: <20170104211957.GD4229@lunn.ch>
References: <1483556184-4176-1-git-send-email-andrew@lunn.ch>
 <20170104.161103.175830630875484681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: volodymyr.bendiuga@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43965 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933318AbdADVUC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 16:20:02 -0500
Content-Disposition: inline
In-Reply-To: <20170104.161103.175830630875484681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 04:11:03PM -0500, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Wed,  4 Jan 2017 19:56:24 +0100
> 
> > +static inline u64 ether_addr_to_u64(const u8 *addr)
> > +{
> > +	u64 u = 0;
> > +	int i;
> > +
> > +	for (i = 0; i < ETH_ALEN; i++)
> > +		u = u << 8 | addr[i];
> > +
> > +	return u;
> > +}
>  ...
> > +static inline void u64_to_ether_addr(u64 u, u8 *addr)
> > +{
> > +	int i;
> > +
> > +	for (i = ETH_ALEN - 1; i >= 0; i--) {
> > +		addr[i] = u & 0xff;
> > +		u = u >> 8;
> > +	}
> > +}
> 
> I think these two routines behave differently on big vs little
> endian.  And I doubt this was your intention.

I don't have a big endian system to test on.

I tried to avoid the usual pitfalls. I don't cast a collection of
bytes to a u64, which i know has no chance of working. Accessing a MAC
address as a byte array should be endian safe. The shift operation
should also be endian safe.

What exactly do you think will behave differently?

     Andrew
