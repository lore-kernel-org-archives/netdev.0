From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND net-next PATCH v5] net: dummy: Introduce dummy virtual
 functions
Date: Wed, 04 Jan 2017 14:09:14 -0500 (EST)
Message-ID: <20170104.140914.1059886799372716512.davem@davemloft.net>
References: <20170104134406.2720-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60332 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdADTJQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 14:09:16 -0500
In-Reply-To: <20170104134406.2720-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Wed,  4 Jan 2017 14:44:06 +0100

> The idea for this was born when testing VF support in iproute2 which was
> impeded by hardware requirements. In fact, not every VF-capable hardware
> driver implements all netdev ops, so testing the interface is still hard
> to do even with a well-sorted hardware shelf.
> 
> To overcome this and allow for testing the user-kernel interface, this
> patch allows to turn dummy into a PF with a configurable amount of VFs.
> 
> Due to the assumption that all PFs are PCI devices, this implementation
> is not completely straightforward: In order to allow for
> rtnl_fill_ifinfo() to see the dummy VFs, a fake PCI parent device is
> attached to the dummy netdev. This has to happen at the right spot so
> register_netdevice() does not get confused. This patch abuses
> ndo_fix_features callback for that. In ndo_uninit callback, the fake
> parent is removed again for the same purpose.
> 
> Joint work with Sabrina Dubroca.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

First of all I really applaud any effort to make the kernel interfaces
more testable, and less dependent upon having specific pieces of hardware.

That being said, all of this seems to be fighting the problem from the
wrong direction.

The device layer is really kidding itself by having what seems like a
generic method in the form of dev_num_vf(), which actually just tests
the bus type and calls a bus specific function on a match.

There is no reason in the world that this cannot be done via proper
device method call, that any bus type or whatever can implement.

Then you don't need any of this stuff, you just hook up the proper
device method to the dummy device and you're good.
