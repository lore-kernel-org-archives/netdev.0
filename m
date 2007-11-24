From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Sat, 24 Nov 2007 13:39:43 +0100
Message-ID: <20071124123943.GA6534@one.firstfloor.org>
References: <20071122343.446909000@suse.de> <200711231435.05788.rusty@rustcorp.com.au> <20071123195330.GA24223@one.firstfloor.org> <200711241553.34744.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Andi Kleen <ak@suse.de>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58117 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbXKXMjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 07:39:45 -0500
Content-Disposition: inline
In-Reply-To: <200711241553.34744.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 24, 2007 at 03:53:34PM +1100, Rusty Russell wrote:
> So, you're saying that there's a problem with in-tree modules using symbols 
> they shouldn't?  Can you give an example?
> 
> > I believe that is fairly important in tree too because the
> > kernel has become so big now that review cannot be the only
> > enforcement mechanism for this anymore.
> 
> If people aren't reviewing, this won't make them review.  I don't think the 

With millions of LOC the primary maintainers cannot review everything.
It's not that anybody is doing a bad job -- it is just so much code
that explicit mechanisms are better than implicit contracts.

> problem is that people are conniving to avoid review.

No of course not -- it is just too much code to let everything
be reviewed by the core subsystem maintainers. But with explicit
marking of internal symbols they would need to look at it because
the relationship will be clearly spelled out in the code.

> > Several distributions have policies that require to 
> > keep the changes to these exported interfaces minimal and that
> > is very hard with thousands of exported symbol.  With name spaces
> > the number of truly publicly exported symbols will hopefully
> > shrink to a much smaller, more manageable set.
> 
> *This* makes sense.  But it's not clear that the burden should be placed on 
> kernel coders.  You can create a list yourself.  How do I tell the difference 
> between "truly publicly exported" symbols and others?

Out of tree solutions generally do not scale.  Nobody else can 
keep up with 2+ Million changes each merge window.

> 
> If a symbol has more than one in-tree user, it's hard to argue against an 

There are still classes of drivers. e.g. for the SCSI example: SD,SG,SR etc.
are more internal while low level drivers like aic7xxx are clearly external
drivers.

> out-of-tree module using the symbol, unless you're arguing against *all* 
> out-of-tree modules.

No, actually namespaces kind of help out of tree modules. Once they only
use interfaces that are really generic driver interfaces and fairly stable
their authors will have much less pain forward porting to newer kernel
version. But currently the authors cannot even know what is an instable
internal interface and what is a generic relatively stable driver level
interface. Namespaces are a mechanism to make this all explicit.

-Andi
