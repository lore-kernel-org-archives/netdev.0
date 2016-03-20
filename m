From: Adam Seering <adam@seering.org>
Subject: Re: [PATCH] appletalk: Pass IP-over-DDP packets through when
 'ipddp0' interface is not present
Date: Sun, 20 Mar 2016 17:19:52 -0400
Message-ID: <1458508792.3317.16.camel@seering.org>
References: <1456237153.4577.35.camel@seering.org>
	 <20160225.143353.284231681606348501.davem@davemloft.net>
	 <1456447597.4577.49.camel@seering.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comomta-po-01v.sys.comcast.net ([96.114.154.250]:55211 "EHLO
	comomta-po-01v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751454AbcCTVUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 17:20:17 -0400
In-Reply-To: <1456447597.4577.49.camel@seering.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-25 at 19:46 -0500, Adam Seering wrote:
> On Thu, 2016-02-25 at 14:33 -0500, David Miller wrote:
> > From: Adam Seering <adam@seering.org>
> > Date: Tue, 23 Feb 2016 09:19:13 -0500
> > 
> > > Let userspace programs transmit and receive raw IP-over-DDP
> > > packets
> > > with a kernel where "ipddp" was compiled as a module but is not
> > loaded
> > > (so no "ipddp0" network interface is exposed).  This makes the
> > "module
> > > is not loaded" behavior match the "module was never compiled"
> > behavior.
> > > 
> > > Signed-off-by: Adam Seering <adam@seering.org>
> > 
> > I think a better approache is to somehow autoload the module.
> 
> Could you elaborate?  Specifically: the kernel currently suppresses
> packets on behalf of the module even after the module is unloaded. 
>  How
> would autoloading the module help with that?
> 

I realize and appreciate that I'm not supposed to nag you folks for
feedback.  But I don't know how to proceed.  So, rather than nag you,
I've filed a bug:

https://bugzilla.kernel.org/show_bug.cgi?id=115031

I've tested my patch; I believe it to be the simplest change that
resolves this bug.  I'm happy to write something else if it would be
cleaner and/or help others, but I would need a more-detailed
explanation of what you're looking for.

I've also filed a ticket downstream:  Red Hat appears to not build the
ipddp module with their stock kernel release, so their users don't hit
this bug.  But Ubuntu does build/ship ipddp; if they likewise didn't,
that would also solve my problem:

https://bugs.launchpad.net/ubuntu/+source/linux-lts-wily/+bug/1559772

Adam
