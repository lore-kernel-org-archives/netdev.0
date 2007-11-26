From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Mon, 26 Nov 2007 12:23:03 +1100
Message-ID: <200711261223.03445.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711241553.34744.rusty@rustcorp.com.au> <20071124123943.GA6534@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41716 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605AbXKZBXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2007 20:23:08 -0500
In-Reply-To: <20071124123943.GA6534@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 24 November 2007 23:39:43 Andi Kleen wrote:
> On Sat, Nov 24, 2007 at 03:53:34PM +1100, Rusty Russell wrote:
> > So, you're saying that there's a problem with in-tree modules using
> > symbols they shouldn't?  Can you give an example?

[ Note: no response to this ]

> > If people aren't reviewing, this won't make them review.  I don't think
> > the
>
> With millions of LOC the primary maintainers cannot review everything.
> It's not that anybody is doing a bad job -- it is just so much code
> that explicit mechanisms are better than implicit contracts.
>
> > problem is that people are conniving to avoid review.
>
> No of course not -- it is just too much code to let everything
> be reviewed by the core subsystem maintainers. But with explicit
> marking of internal symbols they would need to look at it because
> the relationship will be clearly spelled out in the code.

No, a one-line patch adding the module to the set is all they'd see.  There's 
no reason to think this will cause more review.

> > > Several distributions have policies that require to
> > > keep the changes to these exported interfaces minimal and that
> > > is very hard with thousands of exported symbol.  With name spaces
> > > the number of truly publicly exported symbols will hopefully
> > > shrink to a much smaller, more manageable set.
> >
> > *This* makes sense.  But it's not clear that the burden should be placed
> > on kernel coders.  You can create a list yourself.  How do I tell the
> > difference between "truly publicly exported" symbols and others?
>
> Out of tree solutions generally do not scale.  Nobody else can
> keep up with 2+ Million changes each merge window.
>
> > If a symbol has more than one in-tree user, it's hard to argue against an
>
> There are still classes of drivers. e.g. for the SCSI example: SD,SG,SR
> etc. are more internal while low level drivers like aic7xxx are clearly
> external drivers.

Then mark those symbols internal and only allow concurrently-built modules to 
access them.  That's simpler and requires much less maintenance than your 
solution.

> > out-of-tree module using the symbol, unless you're arguing against *all*
> > out-of-tree modules.
>
> No, actually namespaces kind of help out of tree modules. Once they only
> use interfaces that are really generic driver interfaces and fairly stable
> their authors will have much less pain forward porting to newer kernel
> version. But currently the authors cannot even know what is an instable
> internal interface and what is a generic relatively stable driver level
> interface. Namespaces are a mechanism to make this all explicit.

So in your head you have a notion of a kernel API, and you're trying to make 
that API explicit in the code.

Sorry, but no.
Rusty.
