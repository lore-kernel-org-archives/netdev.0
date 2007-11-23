From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Fri, 23 Nov 2007 20:53:30 +0100
Message-ID: <20071123195330.GA24223@one.firstfloor.org>
References: <20071122343.446909000@suse.de> <200711231125.12832.rusty@rustcorp.com.au> <200711230236.22759.ak@suse.de> <200711231435.05788.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:44363 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756912AbXKWTxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 14:53:34 -0500
Content-Disposition: inline
In-Reply-To: <200711231435.05788.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 02:35:05PM +1100, Rusty Russell wrote:
> On Friday 23 November 2007 12:36:22 Andi Kleen wrote:
> > On Friday 23 November 2007 01:25, Rusty Russell wrote:
> > > That's my point.  If there's a whole class of modules which can use a
> > > symbol, why are we ruling out external modules?
> >
> > The point is to get cleaner interfaces.
> 
> But this doesn't change interfaces at all.  It makes modules fail to load 
> unless they're on a permitted list, which now requires maintenance.

The modules wouldn't be using the internal interfaces in the first
place with name spaces in place. This serves as a documentation
on what is considered internal. And if some obscure module (in or
out of tree) wants to use an internal interface they first have
to send the module maintainer a patch and get some review this way.

I believe that is fairly important in tree too because the 
kernel has become so big now that review cannot be the only
enforcement mechanism for this anymore.

Another secondary reason is that there are too many exported interfaces
in general. Several distributions have policies that require to 
keep the changes to these exported interfaces minimal and that
is very hard with thousands of exported symbol.  With name spaces
the number of truly publicly exported symbols will hopefully
shrink to a much smaller, more manageable set.

-Andi
