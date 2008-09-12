From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] retain ABI definitions for obsolete multi-queue packet
 schedulers
Date: Fri, 12 Sep 2008 16:03:51 -0700
Message-ID: <20080912160351.456a347c@extreme>
References: <20080912122548.48945e11@extreme>
	<20080912.153033.157394228.davem@davemloft.net>
	<20080912155830.5ff50c59@extreme>
	<20080912.160154.32092334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33463 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753482AbYILXDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 19:03:55 -0400
In-Reply-To: <20080912.160154.32092334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Sep 2008 16:01:54 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 12 Sep 2008 15:58:30 -0700
> 
> > On Fri, 12 Sep 2008 15:30:33 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Stephen Hemminger <shemminger@vyatta.com>
> > > Date: Fri, 12 Sep 2008 12:25:48 -0700
> > > 
> > > > On Fri, 12 Sep 2008 10:00:11 -0700
> > > > Stephen Hemminger <shemminger@vyatta.com> wrote:
> > > > 
> > > > > Even though the sch_rr qdisc is now gone in 2.6.27, the kernel
> > > > > definitions for the attributes need to be maintained because applications
> > > > > like iproute need to be compatible with older kernels and use santized
> > > > > kernel headers.
> > >  ...
> > > > This should be applied for 2.6.27 since it is a build regression.
> > > 
> > > You use a local copy of this header file in iproute2, you don't even
> > > use the kernel header itself.  It's the worst possible example and
> > > excuse for this change.
> > > 
> > > Nobody references this header directly for these definitions.
> > > The one and only use is using a local copy.
> > > 
> > > iproute2 is the only thing even remotely referencing this stuff.
> > > 
> > > So there is no breakage.  The only breakage is if you, Stephen, decide
> > > to copy the kernel header into iproute2 as-is, and that is your
> > > choice.  :-)
> > 
> > Every release I copy the sanitized kernel headers resulting
> > from 'make headers_install'.  That is how they have been maintained and
> > up until now it worked.  The sch_rr configuration portion was referencing
> > this.  The point of the sanitized headers was to avoid this nonsense.
> 
> But here is the flip side, we actually don't want new applications
> referencing those things, since no kernel from now and into the
> future will ever support those knobs again.  They will always fail.
> 
> Therefore, it makes sense to put the definitions into the one existing
> tool that used it.  You can even put those defines directly into the
> sch_rr iproute2 code, and then your sanitized header bits will
> continue to work transparently.
> 

More likely, I'll just drop sch_rr support from the utilities.
They were just a flash in the pan for a brief period.
