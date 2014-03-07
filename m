From: Joe Perches <joe@perches.com>
Subject: Re: rfc: checkpatch logical line continuations (was IBM Akebono:
 Add support for a new PHY interface to the IBM emac driver)
Date: Fri, 07 Mar 2014 13:45:25 -0800
Message-ID: <1394228725.16156.102.camel@joe-AO722>
References: <1394077948-8395-1-git-send-email-alistair@popple.id.au>
	 <1394077948-8395-3-git-send-email-alistair@popple.id.au>
	 <20140307.154142.488351276799532264.davem@davemloft.net>
	 <1394226164.16156.96.camel@joe-AO722> <20140307213017.GA18769@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alistair@popple.id.au,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Carpenter <error27@gmail.com>,
	Randy Dunlap <rdunlap@infradead.org>
To: josh@joshtriplett.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140307213017.GA18769@cloud>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-07 at 13:30 -0800, josh@joshtriplett.org wrote:
> On Fri, Mar 07, 2014 at 01:02:44PM -0800, Joe Perches wrote:
> > On Fri, 2014-03-07 at 15:41 -0500, David Miller wrote:
> > > From: Alistair Popple <alistair@popple.id.au>
> > > Date: Thu,  6 Mar 2014 14:52:25 +1100
> > > 
> > > > +	out_be32(dev->reg, in_be32(dev->reg) | WKUP_ETH_RGMIIEN
> > > > +		 | WKUP_ETH_TX_OE | WKUP_ETH_RX_IE);
> > > 
> > > When an expression spans multiple lines, the lines should end with
> > > operators rather than begin with them.
> > 
> > That's not in CodingStyle currently.
> 
> It's also not even remotely consistent across existing kernel code, and
> it isn't obvious that there's a general developer consensus on the
> "right" way to write it.

I agree with that.  Stuff that's not in CodingStyle generally
doesn't have a developer consensus.

> > Right now, checkpatch emits a --strict only warning on "&&" or "||"
> > at the beginning of line but that could be changed to any "$Operators"
> > 
> > our $Arithmetic = qr{\+|-|\*|\/|%};
> > our $Operators	= qr{
> > 			<=|>=|==|!=|
> > 			=>|->|<<|>>|<|>|!|~|
> > 			&&|\|\||,|\^|\+\+|--|&|\||$Arithmetic
> > 		  }x;
> > 
> > The ones that likely have a too high false positive rates
> > are the negation "!" and bitwise "~".
> 
> I don't think warning about operators at start of line seems like a good
> idea at all.  There are plenty of cases where putting the operator at
> the start of the line will produce a better result.  (I'd actually
> suggest that in *most* cases.)
> 
> > Also, using perl, it's hard to distinguish between a
> > logical "&" and the address-of "&" as well as the
> > multiplication "*" and indirection "*" so maybe those
> > should be excluded too.
> > 
> > And I think it should only be added as a --strict test.
> 
> Agreed, if even that.

And probably made specific to net/ and drivers/net like
a few other comment style tests until such time as a
consensus exists.
