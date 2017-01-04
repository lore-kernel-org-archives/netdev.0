From: Phil Sutter <phil@nwl.cc>
Subject: Re: [RESEND net-next PATCH v5] net: dummy: Introduce dummy virtual
 functions
Date: Wed, 4 Jan 2017 21:14:46 +0100
Message-ID: <20170104201446.GA23330@orbyte.nwl.cc>
References: <20170104134406.2720-1-phil@nwl.cc>
 <20170104.140914.1059886799372716512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sd@queasysnail.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51315 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032151AbdADUOs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 15:14:48 -0500
Content-Disposition: inline
In-Reply-To: <20170104.140914.1059886799372716512.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 02:09:14PM -0500, David Miller wrote:
> From: Phil Sutter <phil@nwl.cc>
> Date: Wed,  4 Jan 2017 14:44:06 +0100
> 
> > The idea for this was born when testing VF support in iproute2 which was
> > impeded by hardware requirements. In fact, not every VF-capable hardware
> > driver implements all netdev ops, so testing the interface is still hard
> > to do even with a well-sorted hardware shelf.
> > 
> > To overcome this and allow for testing the user-kernel interface, this
> > patch allows to turn dummy into a PF with a configurable amount of VFs.
> > 
> > Due to the assumption that all PFs are PCI devices, this implementation
> > is not completely straightforward: In order to allow for
> > rtnl_fill_ifinfo() to see the dummy VFs, a fake PCI parent device is
> > attached to the dummy netdev. This has to happen at the right spot so
> > register_netdevice() does not get confused. This patch abuses
> > ndo_fix_features callback for that. In ndo_uninit callback, the fake
> > parent is removed again for the same purpose.
> > 
> > Joint work with Sabrina Dubroca.
> > 
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> First of all I really applaud any effort to make the kernel interfaces
> more testable, and less dependent upon having specific pieces of hardware.
> 
> That being said, all of this seems to be fighting the problem from the
> wrong direction.
> 
> The device layer is really kidding itself by having what seems like a
> generic method in the form of dev_num_vf(), which actually just tests
> the bus type and calls a bus specific function on a match.
> 
> There is no reason in the world that this cannot be done via proper
> device method call, that any bus type or whatever can implement.

Yes, this is certainly the proper way to do this. Thanks for your
confirmation!

> Then you don't need any of this stuff, you just hook up the proper
> device method to the dummy device and you're good.

My goal with this (admittedly fugly) hack was to be least intrusive as
possible, allowing people to use the module solely for testing purposes
in case the patch was rejected for other reasons.

I'm glad to see you're not against this practically useless enhancement
of dummy.c per se and so will try to come up with a proper fix for
dev_num_vf() paving the way for a hack-free version of it.

Thanks, Phil
