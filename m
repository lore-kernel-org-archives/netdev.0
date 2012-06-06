From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Wed, 6 Jun 2012 07:21:33 -0400
Message-ID: <20120606112132.GF7683@zod.bos.redhat.com>
References: <20120605192820.GC7683@zod.bos.redhat.com>
 <1338939005.21665.54.camel@deadeye.wl.decadent.org.uk>
 <20120606023842.GD7683@zod.bos.redhat.com>
 <20120606052910.GA674@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410Ab2FFLWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 07:22:22 -0400
Content-Disposition: inline
In-Reply-To: <20120606052910.GA674@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 06, 2012 at 07:29:10AM +0200, Andrew Lunn wrote:
> > The proper fix, from my minimal looking, was one of:
> > 
> > 1) revert the change for ARM that introduced th clk stuff
> > 2) do a similar change as the original commit but with a bunch of
> > #ifdef-ery
> > 3) implement the clkdev API stuff for 32-bit ppc
> > 
> > Honestly, I'd go for either 1 or 2.  The commit that introduced it was
> > broken to begin with, but that isn't my call.
> 
> I broke it. Sorry.
> 
> At the time, there was a push to remove all the #ifdefs. The following
> patchset was doing this:
> 
> https://lkml.org/lkml/2012/4/21/94
> 
> it would provide dummy implementations for those systems without clk
> support. However, it seems that patch set never made it in, and i did
> not declare my dependency on it.
> 
> I'm happy to add #ifdef. However, i would first like to understand
> what was 'broken to begin with'.

Simply that a commit was introduced that did not build on all the
existing platforms the driver supports.  The world is not ARM, or x86,
or PPC32, etc.  I haven't looked to see if it would still function
correctly in the presence of a dummy clk implementation, but if not that
would also be bad.

josh
