From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: rfc: checkpatch logical line continuations (was IBM Akebono: Add
 support for a new PHY interface to the IBM emac driver)
Date: Fri, 07 Mar 2014 13:02:44 -0800
Message-ID: <1394226164.16156.96.camel@joe-AO722>
References: <1394077948-8395-1-git-send-email-alistair@popple.id.au>
	 <1394077948-8395-3-git-send-email-alistair@popple.id.au>
	 <20140307.154142.488351276799532264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>,
	Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140307.154142.488351276799532264.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(added some cc's)

On Fri, 2014-03-07 at 15:41 -0500, David Miller wrote:
> From: Alistair Popple <alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>
> Date: Thu,  6 Mar 2014 14:52:25 +1100
> 
> > +	out_be32(dev->reg, in_be32(dev->reg) | WKUP_ETH_RGMIIEN
> > +		 | WKUP_ETH_TX_OE | WKUP_ETH_RX_IE);
> 
> When an expression spans multiple lines, the lines should end with
> operators rather than begin with them.

That's not in CodingStyle currently.

Right now, checkpatch emits a --strict only warning on "&&" or "||"
at the beginning of line but that could be changed to any "$Operators"

our $Arithmetic = qr{\+|-|\*|\/|%};
our $Operators	= qr{
			<=|>=|==|!=|
			=>|->|<<|>>|<|>|!|~|
			&&|\|\||,|\^|\+\+|--|&|\||$Arithmetic
		  }x;

The ones that likely have a too high false positive rates
are the negation "!" and bitwise "~".

Also, using perl, it's hard to distinguish between a
logical "&" and the address-of "&" as well as the
multiplication "*" and indirection "*" so maybe those
should be excluded too.

And I think it should only be added as a --strict test.



--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
